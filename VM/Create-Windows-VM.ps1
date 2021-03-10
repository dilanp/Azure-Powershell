#Retrieve the resource group
$rg = Get-AzResourceGroup `
-Name psdemo-rg `
-Location uksouth

#Create PSCredential object for the Windows username/password
$password = ConvertTo-SecureString 'password123412123$%^&*' -AsPlainText -Force
$WindowsCred = New-Object System.Management.Automation.PSCredential ('demoadmin', $password)

#Find your image name, enter into the Terminal
New-AzVm -Image

#Create the Windows VM
$vmParams = @{
    ResourceGroupName = 'psdemo-rg'
    Name = 'psdemo-win-1'
    Location = 'uksouth'
    Size = 'Standard_D1'
    Image = 'Win2019Datacenter'
    PublicIpAddressName = 'psdemo-win-1-pip-1'
    Credential = $WindowsCred
    VirtualNetworkName = 'psdemo-vnet-1'
    SubnetName = 'psdemo-subnet-1'
    SecurityGroupName = 'psdemo-win-nsg-1'
    OpenPorts = 3389
}

New-AzVM @vmParams 

#Find the IP address of the new VM
Get-AzPublicIpAddress `
    -ResourceGroupName 'psdemo-rg' `
    -Name 'psdemo-win-1-pip-1' | Select-Object -ExpandProperty IpAddress

#Launch RDP session to new VM...