#requires -Version 7.0

function SfScannerStaticCheck {

    mkdir changed-sources
    mkdir -p "reports"
    sf sgd source delta --to "HEAD" --from "HEAD~1" --output-dir changed-sources/ --generate-delta
    if ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0) {
        Write-Host "::error::Salesforce CLI failed: sf sgd source delta (exit code $LASTEXITCODE)"
        exit [Math]::Min([int]$LASTEXITCODE, 255)
    }

    sf code-analyzer run --rule-selector all --workspace ./changed-sources/force-app --severity-threshold 2 --output-file "reports/code-analyzer-report.csv"
    if ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0) {
        Write-Host "::error::Salesforce CLI failed: sf code-analyzer run (exit code $LASTEXITCODE)"
        exit [Math]::Min([int]$LASTEXITCODE, 255)
    }

    Write-Host ('**********************************************************************************************************')
    Write-Host '*********************** Code Analyzer Scan Completed Successfully  ****************************************'
    Write-Host ('**********************************************************************************************************')
}

SfScannerStaticCheck
