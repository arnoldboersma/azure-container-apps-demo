az group create --name rg-app3 --location westeurope
az deployment group create --resource-group rg-app --template-file core.bicep
az deployment group create --resource-group rg-app --template-file app.bicep

