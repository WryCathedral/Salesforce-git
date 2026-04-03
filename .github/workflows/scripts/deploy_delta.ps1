Param (
    [Parameter(Position = 0)]
    [string]$alias
)
function deploySalesforce {
    Write-Host "******Deploy Salesforce******" 
    Set-Location $pwd\
    $SourceBranch = $env:BUILD_SOURCEBRANCH

	sf alias list 
    sf sgd source delta --to "HEAD" --from "HEAD^" --output .   --ignore-destructive ignoredestructive  --include-destructive includedestructive --ignore-file ignorefile
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
    if ($SourceBranch -match 'refs/heads/main') {
        Write-Host "This is a Main branch!. Executing Deployments with RunLocalTests"       
        sf project deploy start --manifest package/package.xml --post-destructive-changes destructiveChanges/destructiveChanges.xml --ignore-conflicts --target-org $alias --test-level RunLocalTests --wait 120 --verbose
    }
    else{
        sf project deploy start --manifest package/package.xml --post-destructive-changes destructiveChanges/destructiveChanges.xml --ignore-conflicts --target-org $alias --test-level NoTestRun --wait 120 --verbose   
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
        Write-Host "***********************Deployment Canceled*****************************"
        Write-Host "***********************************************************************"
        Write-Host "***********************************************************************"
        Write-Host "##vso[task.complete result=Failed;]Deployment cancelled in org"
        exit 1  
    }
    else {
        Write-Host "***********************************************************************"
        Write-Host "***********************************************************************"    
        Write-Host "*************Failed to Validate Delta Package**************************" 
        Write-Host "***********************************************************************"
        Write-Host "***********************************************************************"   
        exit 1
    }       
}
deploySalesforce $alias
