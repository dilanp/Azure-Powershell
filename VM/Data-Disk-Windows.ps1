
#=============================Create and attach a data disk=============================

#Refer to the resource group.
$rg = Get-AzResourceGroup `
    -Name psdemo-rg `
    -Location 'uksouth'

#Refer to the VM
$vm = Get-AzVM `
    -ResourceGroupName $rg.ResourceGroupName `
    -Name 'psdemo-win-1c' 

#Create the new data disk.
$diskConfig = New-AzDiskConfig `
    -Location 'uksouth' `
    -OsType 'Windows' `
    -CreateOption Empty `
    -DiskSizeGB 50 `
    -SkuName 'Premium_LRS'

$dataDisk = New-AzDisk `
    -ResourceGroupName $rg.ResourceGroupName `
    -DiskName 'psdemo-win-1c-st0' `
    -Disk $diskConfig

#Attach the new data disk to the VM.
$vm = Add-AzVMDataDisk `
    -VM $vm `
    -Name $dataDisk.Name `
    -CreateOption Attach `
    -ManagedDiskId $dataDisk.Id `
    -Lun 1

Update-AzVM `
    -ResourceGroupName 'psdemo-rg' `
    -VM $vm

#=========================Prepare the data disk to be use by Windows OS===============================

#PERFORM THIS OPERATION ON THE SERVER VIA Remote Desktop or PowerShell Remoting.
$newDisk = Get-Disk | Where-Object { $_.Location -like "*LUN 1*" }
$driveLetter = 'P'
$label = "DATA1"

$newDisk | 
	Initialize-Disk -PartitionStyle MBR -PassThru |
    New-Partition -UseMaximumSize -DriveLetter $driveLetter |
    Format-Volume -FileSystem NTFS -NewFileSystemLabel $label -Force

#===========================================Resize a data disk========================================

#Stop and deallocate the VM.
Stop-AzVM `
    -ResourceGroupName 'psdemo-rg' `
    -Name 'psdemo-win-1c' `
    -Force

#Refer to the data disk.
$disk = Get-AzDisk `
    -ResourceGroupName 'psdemo-rg' `
    -DiskName "psdemo-win-1c-st0"

#Update the disk's size.
$disk.DiskSizeGB = 1024

Update-AzDisk `
    -ResourceGroupName 'psdemo-rg' `
    -Disk $disk `
    -DiskName $disk.Name

#Start up the VM again.
Start-AzVm `
    -ResourceGroupName 'psdemo-rg' `
    -Name 'psdemo-win-1c' 

#PERFORM THIS OPERATION ON THE SERVER VIA Remote Desktop or PowerShell Remoting.
diskpart
list volume #we're looking for P:
select volume NN
extend

#========================================Remove a data disk========================================

#Refer to the VM.
$vm = Get-AzVM `
    -ResourceGroupName 'psdemo-rg' `
    -Name 'psdemo-win-1c'

#Remove the disk from the VM.
Remove-AzVMDataDisk `
    -VM $vm `
    -Name "psdemo-win-1c-st0"

Update-AzVM `
    -ResourceGroupName 'psdemo-rg' `
    -VM $vm

#Delete the disk from our Resource Group.
Remove-AzDisk `
    -ResourceGroupName 'psdemo-rg' `
    -DiskName 'psdemo-win-1c-st0'

#====================================Snapshotting the OS disk========================================

#Refer to the VM.
$vm = Get-AzVM `
    -ResourceGroupName 'psdemo-rg' `
    -Name 'psdemo-win-1c'

#Create a snapshot of the OS disk.
$snapshotconfig = New-AzSnapshotConfig `
    -Location 'uksouth' `
    -DiskSizeGB 127 `
    -AccountType 'Premium_LRS' `
    -OsType Windows `
    -CreateOption Empty

New-AzSnapshot `
    -ResourceGroupName 'psdemo-rg' `
    -Snapshot $snapshotconfig `
    -SnapshotName "psdemo-win-1-OSDisk-1-snap-1"

#Get the snapshot just created.
$snapShot = Get-AzSnapshot `
    -ResourceGroupName 'psdemo-rg' `
    -SnapshotName "psdemo-win-1-OSDisk-1-snap-1" 

#Create a new disk from the snapshot.
#If this was a data disk, we could just mount this disk to a VM.
$diskConfig = New-AzDiskConfig `
    -Location $snapShot.Location `
    -SourceResourceId $snapShot.Id `
    -CreateOption Copy
 
$disk = New-AzDisk `
    -ResourceGroupName 'psdemo-rg' `
    -Disk $diskConfig `
    -DiskName 'psdemo-win-1g-OSDisk-1'

#Create a VM from the disk.
$virtualMachine = New-AzVMConfig `
    -VMName 'psdemo-win-1g' `
    -VMSize 'Standard_B1ms'

$virtualMachine = Set-AzVMOSDisk `
    -VM $VirtualMachine `
    -ManagedDiskId $disk.Id `
    -CreateOption Attach `
    -Windows

$vnet = Get-AzVirtualNetwork `
    -ResourceGroupName 'psdemo-rg' `
    -Name 'psdemo-vnet-1'

$nic = New-AzNetworkInterface `
    -ResourceGroupName 'psdemo-rg' `
    -Location 'uksouth' `
    -SubnetId $vnet.Subnets[0].Id `
    -Name 'psdemo-win-1g-nic-1'

$virtualMachine = Add-AzVMNetworkInterface `
    -VM $VirtualMachine `
    -Id $nic.Id

New-AzVM `
    -ResourceGroupName 'psdemo-rg' `
    -VM $virtualMachine `
    -Location $snapshot.Location

#Delete the snapshot when finished.
Remove-AzSnapshot `
    -ResourceGroupName 'psdemo-rg' `
    -SnapshotName "psdemo-win-1-OSDisk-1-snap-1" `
    -Force