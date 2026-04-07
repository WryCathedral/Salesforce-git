# Installs the sfdx-git-delta plugin — adds `sf sgd` commands to diff Git history and emit deploy manifests.
param()

function Install-SfGitDelta {

    # Fail fast if the base CLI was not installed by install_sf_cli.ps1.
    if (-not (Get-Command sf -ErrorAction SilentlyContinue)) {
        Write-Host "******************************************************************************************************************************"
        Write-Host "************** Salesforce CLI ('sf') not found. Please install it first by running Install-SalesforceCLI.ps1 *****************"
        Write-Host "******************************************************************************************************************************"
    exit 1
    }

    # Stable channel — plugin compares commits and writes package.xml / destructiveChanges for deltas.
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