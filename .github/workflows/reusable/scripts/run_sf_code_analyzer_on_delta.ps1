function SfScannerStaticCheck {
    
    mkdir changed-sources
    mkdir -p "reports"
    sf sgd source delta --to "HEAD" --from "HEAD~1" --output-dir changed-sources/ --generate-delta
    sf code-analyzer run --rule-selector all --workspace ./changed-sources/force-app --severity-threshold 2 --output-file "reports/code-analyzer-report.csv"

}
SfScannerStaticCheck