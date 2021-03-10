#Create a new virtual network & subnet
az network vnet create \
--resource-group clidemo-rg \
--name clidemo-vnet-1 \
--address-prefix 172.16.0.0/16 \
--subnet-name clidemo-subnet-1 \
--subnet-prefix 172.16.1.0/24

#Create a public IP address
az network public-ip create \
--resource-group clidemo-rg \
--name clidemo-linux-1-pip-1

#Create a network security group
az network nsg create \
--resource-group clidemo-rg \
--name clidemo-linux-nsg-1

#Create a virtual network interface card & associate with VNET, Public IP and NSG
az network nic create \
--resource-group clidemo-rg  \
--name clidemo-linux-1-nic-1 \
--vnet-name clidemo-vnet-1 \
--subnet clidemo-subnet-1 \
--network-security-group clidemo-linux-nsg-1 \
--public-ip-address clidemo-linux-1-pip-1

#Create the virtual machine
az vm create \
--resource-group clidemo-rg  \
--location uksouth \
--name clidemo-linux-1 \
--image "rhel" \
--nics clidemo-linux-1-nic-1 \
--admin-username "demoadmin" \
--admin-password "##password01"

#Open port 3389 to allow RDP traffic (SSH -> port 22)
az vm open-port \
--resource-group clidemo-rg \
--name clidemo-linux-1 \
--port 3389

#Grab the public IP of the VM
az vm list-ip-addresses \
--name clidemo-linux-1 \
--output table

#Now use IP Address to connect to VM through RDP