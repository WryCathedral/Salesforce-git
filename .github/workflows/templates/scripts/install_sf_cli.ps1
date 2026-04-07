# Installs the Salesforce CLI globally via npm so `sf` is available to the rest of the pipeline.
Param (
    [Parameter(Position = 0)]
    [string]$sfCliVersion

)

function installSFGitDeltaPlugin {
    # Pin @salesforce/cli to the version requested by the workflow (reproducible builds).

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