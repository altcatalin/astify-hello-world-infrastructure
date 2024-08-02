# Fastify Hello World Infrastructure

Infrastructure provisioning for Fastify Hello World.

# Development

```shell

# https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli#2-configure-remote-state-storage-account
STORAGE_ACCOUNT_NAME=tfstate$(openssl rand -hex 4)
CONTAINER_NAME=tfstate

az provider register --namespace 'Microsoft.Storage'
az storage account create --resource-group fastify-hello-world --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob
az storage container create --name tfstate --account-name $STORAGE_ACCOUNT_NAME

terraform init
terraform apply -var="ssh_user=$USER" -var="source_image_name={{SOURCE_IMAGE_NAME}}"
terraform destroy -var="ssh_user=$USER" -var="source_image_name={{SOURCE_IMAGE_NAME}}"

pip install pre-commit
pre-commit --version
pre-commit install
```
