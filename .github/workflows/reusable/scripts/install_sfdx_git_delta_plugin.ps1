param()

function Install-SfGitDelta {

    if (-not (Get-Command sf -ErrorAction SilentlyContinue)) {
        Write-Host "******************************************************************************************************************************"
        Write-Host "************** Salesforce CLI ('sf') not found. Please install it first by running Install-SalesforceCLI.ps1 *****************"
        Write-Host "******************************************************************************************************************************"
    exit 1
    }

    'y' | sf plugins install sfdx-git-delta@stable
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install sfdx-git-delta plugin."
    }

    Write-Host "***********************************************************************************************************"
    Write-Host "*********************  SFDX-GIT-DELTA plugin Installation Completed  **************************************"
    Write-Host "***********************************************************************************************************"

    sf plugins
}

Install-SfGitDelta