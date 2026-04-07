param()

function Install-SfdxScanner {

    if (-not (Get-Command sf -ErrorAction SilentlyContinue)) {
        Write-Host "******************************************************************************************************************************"
        Write-Host "************** Salesforce CLI ('sf') not found. Please install it first by running Install-SalesforceCLI.ps1 *****************"
        Write-Host "******************************************************************************************************************************"
    exit 1
    }

    'y' | sf plugins install code-analyzer
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install sfdx-scanner plugin."
    }

    Write-Host "***********************************************************************************************************"
    Write-Host "******************  Salesforce CLI Scanner plugin Installation Completed  *********************************"
    Write-Host "***********************************************************************************************************"

    sf plugins
}

Install-SfdxScanner