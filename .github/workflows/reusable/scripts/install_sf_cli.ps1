Param (
    [Parameter(Position = 0)]
    [string]$sfCliVersion

)

function installSFGitDeltaPlugin {

    Write-Host "***********************************************************************************************************"
    Write-Host "***********************  Installing Salesforce CLI" $sfCliVersion  "***************************************"
    Write-Host "***********************************************************************************************************"

    npm install --global @salesforce/cli@$sfCliVersion

    Write-Host "***********************************************************************************************************"
    Write-Host "*********************** Salesforce CLI Installation is Completed  *****************************************"
    Write-Host "***********************************************************************************************************"

    sf --version

}

installSFGitDeltaPlugin  -sfCliVersion $sfCliVersion 