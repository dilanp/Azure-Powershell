#Create a new virtual network & subnet
az network vnet create \
--resource-group clidemo-rg \
--name clidemo-vnet-1 \
--address-prefix 172.16.0.0/16 \
--subnet-name clidemo-subnet-1 \
--subnet-prefix 172.16.1.0/24
