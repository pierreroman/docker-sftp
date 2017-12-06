
#!/bin/bash

# Change these four parameters as needed
ACI_STORAGE_ACCOUNT_NAME=mystorageaccount$RANDOM
ACI_RESOURCE_GROUP=RG-SFTP
ACI_LOCATION=eastus
ACI_SHARE_NAME=acishare

# Create resource group
az group create -l $ACI_LOCATION -n $ACI_RESOURCE_GROUP

# Create the storage account with the parameters
az storage account create -n $ACI_STORAGE_ACCOUNT_NAME -g $ACI_RESOURCE_GROUP -l $ACI_LOCATION --sku Standard_LRS


# Export the connection string as an environment variable. The following 'az storage share create' command
# references this environment variable when creating the Azure file share.
export AZURE_STORAGE_CONNECTION_STRING=`az storage account show-connection-string -n $ACI_STORAGE_ACCOUNT_NAME -g $ACI_RESOURCE_GROUP -o tsv`

# Create the file share
az storage share create -n $ACI_SHARE_NAME

# Deploy container 

az container create \
    --resource-group $ACI_PERS_RESOURCE_GROUP \
    --name hellofiles \
    --image writl/sftp \
    --ip-address Public \
    --ports 22 \
    --azure-file-volume-account-name $ACI_PERS_STORAGE_ACCOUNT_NAME \
    --azure-file-volume-account-key $STORAGE_KEY \
    --azure-file-volume-share-name $ACI_PERS_SHARE_NAME \
    --azure-file-volume-mount-path /data/incoming