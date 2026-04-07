#requires -Version 7.0
<#
.SYNOPSIS
    Validate (dry-run) full deploy of force-app against a Salesforce org.
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

function Invoke-FullValidation {
    $sourceDir = 'force-app'
    if (-not (Test-Path -LiteralPath $sourceDir)) {
        Write-Host "::error::Source directory '$sourceDir' not found."
        exit 1
    }

    sf alias list
    Assert-SfExitCode 'sf alias list'

    Write-Host 'Running full-metadata validation (dry-run) with RunLocalTests.'
    sf project deploy start --source-dir $sourceDir --test-level RunLocalTests `
        --target-org $Alias --wait 120 --dry-run --verbose
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

Invoke-FullValidation
