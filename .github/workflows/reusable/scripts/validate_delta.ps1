#requires -Version 7.0
<#
.SYNOPSIS
    Dry-run deploy (validation) of git-delta package against a Salesforce org.
    Expects env from reusable workflows: SYSTEM_PULLREQUEST_TARGETBRANCH (PR base ref).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$Alias
)

function Assert-SfExitCode {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StepName
    )
    if ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0) {
        Write-Host "::error::Salesforce CLI failed: $StepName (exit code $LASTEXITCODE)"
        exit [Math]::Min([int]$LASTEXITCODE, 255)
    }
}

function Copy-DeltaArtifacts {
    $timestamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
    $artifactFolder = 'artifacts'
    if (-not (Test-Path -LiteralPath $artifactFolder)) {
        New-Item -ItemType Directory -Force -Path $artifactFolder | Out-Null
    }
    Copy-Item -LiteralPath 'package/package.xml' -Destination (Join-Path $artifactFolder "package_$timestamp.xml") -Force
    Copy-Item -LiteralPath 'destructiveChanges/destructiveChanges.xml' -Destination (Join-Path $artifactFolder "destructiveChanges_$timestamp.xml") -Force
    Write-Host "Artifacts: $artifactFolder/package_$timestamp.xml, destructiveChanges_$timestamp.xml"
}

function Invoke-DeltaValidation {
    $prTargetBranch = $env:SYSTEM_PULLREQUEST_TARGETBRANCH

    sf alias list
    Assert-SfExitCode 'sf alias list'

    sf sgd source delta --to 'HEAD' --from 'HEAD^' --output . `
        --ignore-destructive ignoredestructive `
        --include-destructive includedestructive `
        --ignore-file ignorefile
    Assert-SfExitCode 'sf sgd source delta'

    if (-not (Test-Path -LiteralPath 'package/package.xml')) {
        Write-Host '::error::package/package.xml not found after delta generation.'
        exit 1
    }
    if (-not (Test-Path -LiteralPath 'destructiveChanges/destructiveChanges.xml')) {
        Write-Host '::error::destructiveChanges/destructiveChanges.xml not found after delta generation.'
        exit 1
    }

    Copy-DeltaArtifacts

    Write-Host '--- package.xml ---'
    Get-Content -LiteralPath 'package/package.xml'
    Write-Host '--- destructiveChanges.xml ---'
    Get-Content -LiteralPath 'destructiveChanges/destructiveChanges.xml'

    $packageXmlRaw = Get-Content -LiteralPath 'package/package.xml' -Raw
    $useRunLocalTests =
        ($prTargetBranch -match 'refs/heads/main') -or
        ($packageXmlRaw -match '<name>ApexClass</name>') -or
        ($packageXmlRaw -match '<name>ValidationRule</name>') -or
        ($packageXmlRaw -match '<name>Flow</name>')

    if ($useRunLocalTests) {
        Write-Host 'Running validation with RunLocalTests.'
        sf project deploy start --manifest package/package.xml --post-destructive-changes destructiveChanges/destructiveChanges.xml `
            --target-org $Alias --test-level RunLocalTests --dry-run --wait 120 --verbose
    }
    else {
        Write-Host 'Running validation with NoTestRun.'
        sf project deploy start --manifest package/package.xml --post-destructive-changes destructiveChanges/destructiveChanges.xml `
            --target-org $Alias --test-level NoTestRun --dry-run --wait 120 --verbose
    }
    Assert-SfExitCode 'sf project deploy start (dry-run)'

    $deploymentStatus = sf project deploy report --target-org $Alias --use-most-recent --wait 120
    Assert-SfExitCode 'sf project deploy report'

    if ($deploymentStatus | Select-String -Pattern 'Succeeded' -Quiet) {
        Write-Host 'Validation succeeded.'
        return
    }
    if ($deploymentStatus | Select-String -Pattern 'Failed' -Quiet) {
        Write-Host '::error::Validation failed in org.'
        exit 1
    }
    if ($deploymentStatus | Select-String -Pattern 'Canceled' -Quiet) {
        Write-Host '::error::Validation canceled in org.'
        exit 1
    }

    Write-Host '::error::Unexpected validation status; expected Succeeded, Failed, or Canceled.'
    exit 1
}

Invoke-DeltaValidation
