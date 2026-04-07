#requires -Version 7.0
# PR-only: builds a tiny delta copy of metadata then runs Code Analyzer and writes CSV under reports/.

function SfScannerStaticCheck {

    # Output folders for delta slice and analyzer reports consumed by the upload-artifact step.
    mkdir changed-sources
    mkdir -p "reports"
    # Last commit vs its parent — quick delta for CI (not the same range as full validate/deploy).
    sf sgd source delta --to "HEAD" --from "HEAD~1" --output-dir changed-sources/ --generate-delta
    if ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0) {
        Write-Host "::error::Salesforce CLI failed: sf sgd source delta (exit code $LASTEXITCODE)"
        exit [Math]::Min([int]$LASTEXITCODE, 255)
    }

    # Scan only the delta workspace; severity-threshold 2 aligns with typical warning/error gating.
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
