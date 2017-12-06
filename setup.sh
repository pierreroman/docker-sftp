
#!/bin/bash

# Change these four parameters as needed
ACI_STORAGE_ACCOUNT_NAME=sftpstorage$RANDOM
ACI_RESOURCE_GROUP=RG-SFTP
ACI_LOCATION=eastus
ACI_SHARE_NAME=sftpshare
ACI_CONTAINER_NAME=sftpcontainer

# Create resource group
az group create -l $ACI_LOCATION -n $ACI_RESOURCE_GROUP

# Create the storage account with the parameters
az storage account create -n $ACI_STORAGE_ACCOUNT_NAME -g $ACI_RESOURCE_GROUP -l $ACI_LOCATION --sku Standard_LRS


# Export the connection string as an environment variable. The following 'az storage share create' command
# references this environment variable when creating the Azure file share.
export AZURE_STORAGE_CONNECTION_STRING=`az storage account show-connection-string -n $ACI_STORAGE_ACCOUNT_NAME -g $ACI_RESOURCE_GROUP -o tsv`

# Create the file share
az storage share create -n $ACI_SHARE_NAME

# Retreive storage account key

STORAGE_ACCOUNT=$(az storage account list --resource-group $ACI_RESOURCE_GROUP --query "[?contains(name,'$ACI_PERS_STORAGE_ACCOUNT_NAME')].[name]" -o tsv)
echo $STORAGE_ACCOUNT

STORAGE_KEY=$(az storage account keys list -g $ACI_RESOURCE_GROUP -n $STORAGE_ACCOUNT --query "[0].value" -o tsv)
echo $STORAGE_KEY

# Deploy container 

az container create -g $ACI_RESOURCE_GROUP \
    -n $ACI_CONTAINER_NAME \
    --os-type Linux \
    --image pierreroman/sftp-azr \
    --ip-address Public \
    --port 22 \
    --azure-file-volume-account-name $ACI_STORAGE_ACCOUNT_NAME \
    --azure-file-volume-account-key $STORAGE_KEY \
    --azure-file-volume-share-name $ACI_SHARE_NAME \
    --azure-file-volume-mount-path /data/incoming \
    --environment-variables USER="sftpuser" PASS="P@ssw0rd123"

CONTAINER_IP=$(az container show --name $ACI_CONTAINER_NAME  --resource-group $ACI_RESOURCE_GROUP --query ipAddress.ip)
echo
echo "the IP address of the container is " $CONTAINER_IP