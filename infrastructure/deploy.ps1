az group create --name rg-app3 --location westeurope
az deployment group create --resource-group rg-app3 --template-file core.bicep
az deployment group create --resource-group rg-app3 --template-file app.bicep

