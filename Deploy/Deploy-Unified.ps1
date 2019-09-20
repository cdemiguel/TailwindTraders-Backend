Param(
    [parameter(Mandatory=$true)][string]$resourceGroup,
    [parameter(Mandatory=$true)][string]$location,
    [parameter(Mandatory=$true)][string]$subscription,
    [parameter(Mandatory=$false)][string]$clientId,
    [parameter(Mandatory=$false)][string]$password,
    [parameter(Mandatory=$false)][bool]$deployAks=$true
)
$gValuesFile="configFile.yaml"

Push-Location $($MyInvocation.InvocationName | Split-Path)

# Update the extension to make sure you have the latest version installed
az extension add --name aks-preview
az extension update --name aks-preview

## Deploy ARM
.\Deploy-Arm-Azure.ps1 -resourceGroup $resourceGroup -location $location -clientId $clientId -password $password -deployAks $deployAks

## Connecting kubectl to AKS
Write-Host "Login in your account" -ForegroundColor Yellow
az login

Write-Host "Choosing your subscription" -ForegroundColor Yellow
az account set --subscription $subscription

Write-Host "Retrieving Aks Name" -ForegroundColor Yellow
$aksName = $(az aks list -g $resourceGroup -o json | ConvertFrom-Json).name
Write-Host "The name of your AKS: $aksName" -ForegroundColor Yellow

Write-Host "Retrieving credentials" -ForegroundColor Yellow
az aks get-credentials -n $aksName -g $resourceGroup

# ## Add Tiller
.\Add-Tiller.ps1

# ## Generate Config
.\Generate-Config.ps1 -resourceGroup $resourceGroup -outputFile "helm\__values\$gValuesFile"

## Create Secrets
$acrName = $(az acr list --resource-group $resourceGroup --subscription $subscription -o json | ConvertFrom-Json).name
Write-Host "The Name of your ACR: $acrName" -ForegroundColor Yellow
.\Create-Secret.ps1 -resourceGroup $resourceGroup -acrName $acrName

# Build an Push
.\Build-Push.ps1 -resourceGroup $resourceGroup -acrName $acrName -isWindows $false

# Deploy images in AKS
.\Deploy-Images-Aks.ps1 -aksName $aksName -resourceGroup $resourceGroup -charts "*" -acrName $acrName -valuesFile "__values\$gValuesFile"

# Deploy pictures in AKS
$storageName = $(az resource list --resource-group $resourceGroup --resource-type Microsoft.Storage/storageAccounts -o json | ConvertFrom-Json).name
.\Deploy-Pictures-Azure.ps1 -resourceGroup $resourceGroup -storageName $storageName

Pop-Location