# Allure TestOps deploy in kubernetes

## Deploy description

https://docs.qameta.io/allure-testops/getstarted/kubernetes/

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
