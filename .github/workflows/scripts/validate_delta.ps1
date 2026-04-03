Param (
    [Parameter(Position = 0)]
    [string]$alias
)
function deploySalesforce {
    Write-Host "******Deploy Salesforce******" 
    Set-Location $pwd\
    $prTargetBranch = $env:SYSTEM_PULLREQUEST_TARGETBRANCH  

    sf alias list
    sf sgd source delta --to "HEAD" --from "HEAD^" --output .   --ignore-destructive ignoredestructive  --include-destructive includedestructive  --ignore-file ignorefile

     # ---- NEW SECTION: Save XMLs to artifacts folder ----
    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $artifactFolder = "artifacts"

    if (!(Test-Path $artifactFolder)) {
        New-Item -ItemType Directory -Force -Path $artifactFolder | Out-Null
    }

    Copy-Item -Path "package/package.xml" -Destination "$artifactFolder/package_$timestamp.xml"
    Copy-Item -Path "destructiveChanges/destructiveChanges.xml" -Destination "$artifactFolder/destructiveChanges_$timestamp.xml"

    Write-Host "******** Package.xml saved to: $artifactFolder/package_$timestamp.xml ****"
    Write-Host "******** DestructiveChanges.xml saved to: $artifactFolder/destructiveChanges_$timestamp.xml ****"

    Write-Host "***********************************************************************"
    Write-Host "***********************************************************************"
    Write-Host "***********Added/Modified files in package.xml*************************"
    Write-Host "***********************************************************************"
    Write-Host "***********************************************************************"
    cat package/package.xml   
    Write-Host "***********************************************************************"
    Write-Host "***********************************************************************"
    Write-Host "***********Removed/Deleted files in destructiveChanges.xml*************"
    Write-Host "***********************************************************************"
    Write-Host "***********************************************************************"
    cat destructiveChanges/destructiveChanges.xml
    Write-Host "***********************************************************************"
    Write-Host "***********************************************************************"
    Write-Host "***********************************************************************"
    Write-Host "***********************************************************************"        
    $PackageXml = Get-Content package/package.xml
    if ($prTargetBranch -match 'refs/heads/main') {
        Write-Host "This is a Main branch!. Executing Validations with RunLocalTests"  
        sf project deploy start --manifest package/package.xml --post-destructive-changes destructiveChanges/destructiveChanges.xml --target-org $alias --test-level RunLocalTests --dry-run --wait 120 --verbose
    } 
    elseif ($PackageXml -match '<name>ApexClass</name>' -or $PackageXml -match '<name>ValidationRule</name>' -or $PackageXml -match '<name>Flow</name>'){
        sf project deploy start --manifest package/package.xml --post-destructive-changes destructiveChanges/destructiveChanges.xml --target-org $alias --test-level RunLocalTests --dry-run --wait 120 --verbose
    }
    else{   
        sf project deploy start --manifest package/package.xml --post-destructive-changes destructiveChanges/destructiveChanges.xml --target-org $alias --test-level NoTestRun --dry-run --wait 120 --verbose
    }

    $deploymentStatus = sf project deploy report --target-org $alias --use-most-recent --wait 120
    if ($deploymentStatus | Select-String -Pattern "Succeeded") {
        Write-Host "***********************************************************************"
        Write-Host "***********************************************************************"        
        Write-Host "***********************Deployment Succeeded****************************"
        Write-Host "***********************************************************************"
        Write-Host "***********************************************************************"     
    }
    elseif ($deploymentStatus | Select-String -Pattern "Failed") {
        Write-Host "***********************************************************************"
        Write-Host "***********************************************************************"        
        Write-Host "***********************Deployment Failed*******************************"
        Write-Host "***********************************************************************"
        Write-Host "***********************************************************************"
        exit 1  
    }   
    elseif ($deploymentStatus | Select-String -Pattern "Canceled") {
        Write-Host "***********************************************************************"
        Write-Host "***********************************************************************"        
        Write-Host "***********************Validation Canceled*****************************"
        Write-Host "***********************************************************************"
        Write-Host "***********************************************************************"
        Write-Host "##vso[task.complete result=Failed;]Validation cancelled in org"
        exit 1  
    }
    else {
        Write-Host "***********************************************************************"
        Write-Host "***********************************************************************"    
        Write-Host "*************Failed to Validate Delta Package**************************" 
        Write-Host "***********************************************************************"
        Write-Host "***********************************************************************"   
        # exit 1
    }     
}
deploySalesforce $alias
