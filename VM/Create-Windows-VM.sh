#Create a new resource group
az group create \
--name clidemo-rg \
--location uksouth

#Create a new virtual network & subnet
az network vnet create \
--resource-group clidemo-rg \
--name clidemo-vnet-1 \
--address-prefix 172.16.0.0/16 \
--subnet-name clidemo-subnet-1 \
--subnet-prefix 172.16.1.0/24

#Create public IP address
az network public-ip create \
--resource-group clidemo-rg \
--name clidemo-win-1-pip-1

#Create a network security group
az network nsg create \
--resource-group clidemo-rg \
--name clidemo-win-nsg-1

#Create a virtual network interface card and associate with VNET, public IP and NSG
az network nic create \
--resource-group clidemo-rg \
--name clidemo-win-1-nic-1 \
--vnet-name clidemo-vnet-1 \
--subnet clidemo-subnet-1 \
--network-security-group clidemo-win-nsg-1 \
--public-ip-address clidemo-win-1-pip-1

#Create the virtual machine
az vm create \
--resource-group clidemo-rg \
--name clidemo-win-1 \
--location uksouth \
--nics clidemo-win-1-nic-1 \
--image win2019datacenter \
--admin-username "demoadmin" \
--admin-password "##password01"

#Open port 3389 to allow RDP traffic to the VM
az vm open-port \
--port 3389 \
--resource-group clidemo-rg \
--name clidemo-win-1

#Grab the public IP of the VM
az vm list-ip-addresses \
--name clidemo-win-1  \
--output table

#Now use IP Address to connect to VM through RDP