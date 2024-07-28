group=Barabash_Sandbox
username=adminuser
password='SuperPassword123!@#'

az network vnet create \
  -n vm-vnet \
  -g $group \
  -l eastus \
  --address-prefixes '192.168.0.0/16' \
  --subnet-name subnet \
  --subnet-prefixes '192.168.1.0/24'
  
az vm availability-set create \
  -n vm-availability-set \
  -l eastus \
  -g $group

for NUM in 1 2 3
do
  az vm create \
    -n vm-0$NUM \
    -g $group \
    -l eastus \
    --size Standard_B1s \
    --image Win2019Datacenter \
    --admin-username $username \
    --admin-password $password \
    --vnet-name vm-vnet \
    --subnet subnet \
    --public-ip-address "" \
    --availability-set vm-availability-set \
	--nsg vm-nsg
done

for NUM in 1 2 3
do
  az vm open-port -g $group --name vm-0$NUM --port 80
done

for NUM in 1 2 3
do
  az vm extension set \
    --name CustomScriptExtension \
    --vm-name vm-0$NUM \
    -g $group \
    --publisher Microsoft.Compute \
    --version 1.8 \
    --settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'
done



