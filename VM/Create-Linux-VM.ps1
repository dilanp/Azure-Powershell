#Retrieve the resource group
$rg = Get-AzResourceGroup `
-Name psdemo-rg `
-Location uksouth

#Create a virtual network
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
-Name psdemo-subnet-1 `
-AddressPrefix 172.17.1.0/24

$vnet = New-AzVirtualNetwork `
-ResourceGroupName $rg.ResourceGroupName `
-Location $rg.Location `
-Name psdemo-vnet-1 `
-AddressPrefix 172.17.0.0/16 `
-Subnet $subnetConfig

#Create public IP address
$pip = New-AzPublicIpAddress `
-ResourceGroupName $rg.ResourceGroupName `
-Location $rg.Location `
-Name psdemo-linux-1-pip-1 `
-AllocationMethod Static

#Create network security group for SSH
$rule1 = New-AzNetworkSecurityRuleConfig `
-Name rdp-rule `
-Description 'Allow RDP' `
-Access Allow `
-Protocol Tcp `
-Direction Inbound `
-Priority 100 `
-SourceAddressPrefix Internet `
-SourcePortRange * `
-DestinationAddressPrefix * `
-DestinationPortRange 22

$nsg = New-AzNetworkSecurityGroup `
-ResourceGroupName $rg.ResourceGroupName `
-Location $rg.Location `
-Name psdemo-linux-nsg-1 `
-SecurityRules $rule1

#Create a virtual network interface card and associate with subnet, public IP and NSG
$subnet = $vnet.Subnets | Where-Object { $_.Name -eq 'psdemo-subnet-1' }

$nic = New-AzNetworkInterface `
-ResourceGroupName $rg.ResourceGroupName `
-Location $rg.Location `
-Name psdemo-linux-1-nic-1 `
-Subnet $subnet `
-PublicIpAddress $pip `
-NetworkSecurityGroup $nsg

#Set virtual machine configuration
$linuxVmConfig = New-AzVMConfig `
-VMName psdemo-linux-1 `
-VMSize Standard_D1

#Set the comptuer name, OS type and, auth methods.
$password = ConvertTo-SecureString 'password123412123$%^&*' -AsPlainText -Force
$LinuxCred = New-Object System.Management.Automation.PSCredential ('demoadmin', $password)
$LinuxVmConfig = Set-AzVMOperatingSystem `
-VM $LinuxVmConfig `
-Linux `
-ComputerName psdemo-linux-1 `
-DisablePasswordAuthentication `
-Credential $LinuxCred

#Read in our SSH Keys and add to the vm config
$sshPublicKey = Get-Content "~/.ssh/id_rsa.pub"
Add-AzVMSshPublicKey `
-VM $LinuxVmConfig `
-KeyData $sshPublicKey `
-Path "/home/demoadmin/.ssh/authorized_keys"

#6d - Get the VM image name, and set it in the VM config in this case RHEL/latest
Get-AzVMImageSku -Location $rg.Location -PublisherName "Redhat" -Offer "rhel"
$LinuxVmConfig = Set-AzVMSourceImage `
-VM $LinuxVmConfig `
-PublisherName 'Redhat' `
-Offer 'rhel' `
-Skus '8' `
-Version 'latest' 

#Assign the created network interface to the vm
$LinuxVmConfig = Add-AzVMNetworkInterface `
-VM $LinuxVmConfig `
-Id $nic.Id 

# Create a virtual machine, passing in the VM Configuration, network, image etc are in the config.
New-AzVM `
-ResourceGroupName $rg.ResourceGroupName `
-Location $rg.Location `
-VM $LinuxVmConfig

$MyIP = Get-AzPublicIpAddress `
-ResourceGroupName $rg.ResourceGroupName `
-Name $pip.Name | Select-Object -ExpandProperty IpAddress

#Connect to our VM via SSH
ssh -l demoadmin $MyIP