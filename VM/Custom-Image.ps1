#===========================Create a custom Windows Image ====================================

#PREPARE WINDOWS/LINUX VM. 
#WINDOWS - Open an RDP session and run this in command prompt to generalize and shut down the VM. 
%WINDIR%\system32\sysprep\sysprep.exe /generalize /shutdown /oobe
#LINUX - Open an SSH session and run the following commands to deprovision the VM.
ssh user_name@public_ip_address
sudo waagent -deprovision+user -force
exit

#Get the Resource Group reference.
$rg = Get-AzResourceGroup `
    -Name 'psdemo-rg' `
    -Location 'uksouth'

#Get the VM reference.
$vm = Get-AzVm `
    -ResourceGroupName $rg.ResourceGroupName `
    -Name "psdemo-win-1"

#Deallocate the VM.
Stop-AzVM `
    -ResourceGroupName $rg.ResourceGroupName `
    -Name $vm.Name `
    -Force

#Make sure the VM is deallocated.
Get-AzVM `
    -ResourceGroupName $rg.ResourceGroupName `
    -Name $vm.Name `
    -Status

#Generalized the VM.
Set-AzVM `
    -ResourceGroupName $rg.ResourceGroupName `
    -Name $vm.Name `
    -Generalized

#Create an Image Configuration from the VM.
$image = New-AzImageConfig `
    -Location $rg.Location `
    -SourceVirtualMachineId $vm.ID

#Create a VM image from the custom image config.
New-AzImage `
    -ResourceGroupName $rg.ResourceGroupName `
    -Image $image `
    -ImageName "psdemo-win-ci-1"

#Make sure the custom image has been created.
Get-AzImage -ResourceGroupName $rg.ResourceGroupName

#Now you may delete the deallocated source VM.

#==========================Deploy from a custom Windows Image=============================

#Make sure the custom image is available in resource group.
Get-AzImage -ResourceGroupName $rg.ResourceGroupName

#Create Windows credentials
$password = ConvertTo-SecureString 'password123412123$%^&*' -AsPlainText -Force
$windowsCred = New-Object System.Management.Automation.PSCredential ('demoadmin', $password)

#Create the VM from the custom image.
New-AzVm `
    -ResourceGroupName $rg.ResourceGroupName `
    -Name "psdemo-win-1c" `
    -ImageName "psdemo-win-ci-1" `
    -Location 'uksouth' `
    -Credential $WindowsCred `
    -VirtualNetworkName 'psdemo-vnet-2' `
    -SubnetName 'psdemo-subnet-2' `
    -SecurityGroupName 'psdemo-win-nsg-2' `
    -OpenPorts 3389

#Check the status of our provisioned VM from the Image.
Get-AzVm `
    -ResourceGroupName $rg.ResourceGroupName `
    -Name "psdemo-win-1c"
