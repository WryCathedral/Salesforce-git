Param (
    [Parameter(Position = 0)]
    [string]$alias
)
function validateSalesforce {
    Write-Host "******Start of the Added/Modified  Validation******" 
    Set-Location $pwd\  
    sf alias list
    sf deploy metadata --source-dir $pwd/force-app --test-level RunLocalTests --target-org $alias --wait 120 --dry-run  #Validate Full Force-app Folder
 
}
validateSalesforce alias $alias