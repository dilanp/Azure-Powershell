#Create a new resource group
New-AzResourceGroup `
-Name psdemo-rg `
-Location uksouth

#Retrieve resource group
$rg = Get-AzResourceGroup `
-Name psdemo-rg `
-Location uksouth
