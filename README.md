# This repositiry is outdated and mustnt' be used for the deployment of Allure TestOps

[Use this helm chart instead](https://github.com/qameta/testops-deploy-helm-chart)


# Allure TestOps ver 4 deploy in kubernetes

## Deploy description

https://docs.qameta.io/allure-testops/install/kubernetes/

## values.yaml template file

https://github.com/qameta/allure-testops-deployment/blob/master/charts/allure-testops/values.yaml


## Helm commands

```bash
helm repo add qameta https://dl.qameta.io/artifactory/helm
helm repo update
helm upgrade --install allure-testops qameta/allure-testops -f values.yaml
```

## Allure TestOps release upgrade

1. update values.yaml `version`

```yaml
version: 4.1.0
```
The most recent recommended release: https://docs.qameta.io/allure-testops/release-notes/

2. Run Helm upgrade

```bash
helm repo update
helm upgrade --install allure-testops qameta/allure-testops -f values.yaml
```

## Allure TestOps Deploy update

1. update values.yaml 
2. Run Helm upgrade

```bash
helm repo update
helm upgrade --install allure-testops qameta/allure-testops -f values.yaml
```

## Azure Special Requirements

```shell
# Create Resource Group
az group create --name "testops-azure-minio" --location "WestUS"

# Create Storage Account
az storage account create \
    --name "testops-azure-minio-storage" \
    --kind BlobStorage \
    --sku Standard_LRS \
    --access-tier {your_tier} \
    --resource-group "testops-azure-minio" \
    --location "WestUS"

# Retrieve Account Key    
az storage account show-connection-string \
    --name "testops-azure-minio-storage" \
    --resource-group "testops-azure-minio"

# Create AppService Plan    
az appservice plan create \
    --name "testops-azure-minio-app-plan" \
    --is-linux \
    --sku B1 \
    --resource-group "testops-azure-minio" \
    --location "WestUS"

# Create Minio WebApp    
az webapp create \
    --name "testops-minio-app" \
    --deployment-container-image-name "minio/minio" \
    --plan "testops-azure-minio-app-plan" \
    --resource-group "testops-azure-minio"
    
az webapp config appsettings set \
    --settings "MINIO_ACCESS_KEY={accessKey}" "MINIO_SECRET_KEY={secretKey}" "PORT=9000" \
    --name "testops-minio-app" \
    --resource-group "testops-azure-minio"
    
# Startup command
az webapp config set \
    --startup-file "gateway azure" \
    --name "testops-minio-app" \
    --resource-group "testops-azure-minio"
    
# Then s3 will be available at https://testops-minio-app.azurewebsites.net
```

## Uninstalling the deployment

```bash
helm delete allure-testops
```
