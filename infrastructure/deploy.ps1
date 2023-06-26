
az group create --name rg-app --location westeurope
az deployment group create --resource-group rg-app --template-file core.bicep