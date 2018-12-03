Param(
    [parameter(Mandatory=$false)][string]$name = "my-tt",
    [parameter(Mandatory=$false)][string]$aksName,
    [parameter(Mandatory=$false)][string]$resourceGroup,
    [parameter(Mandatory=$false)][string]$acrName,
    [parameter(Mandatory=$false)][string]$acrLogin,
    [parameter(Mandatory=$false)][string]$tag="latest",
    [parameter(Mandatory=$false)][string]$charts = "*",
    [parameter(Mandatory=$false)][string]$valueSFile = "gvalues.yml",
    [parameter(Mandatory=$false)][string]$afHost = "http://your-product-visits-af-here"
)

function validate {
    $valid = $true


    if ([string]::IsNullOrEmpty($aksName)) {
        Write-Host "No AKS name. Use -aksName to specify name" -ForegroundColor Red
        $valid=$false
    }
    if ([string]::IsNullOrEmpty($resourceGroup))  {
        Write-Host "No resource group. Use -resourceGroup to specify resource group." -ForegroundColor Red
        $valid=$false
    }

    if ([string]::IsNullOrEmpty($aksHost))  {
        Write-Host "AKS host of HttpRouting can't be found. Are you using right AKS ($aksName) and RG ($resourceGroup)?" -ForegroundColor Red
        $valid=$false
    }     
    if ([string]::IsNullOrEmpty($acrLogin))  {
        Write-Host "ACR login server can't be found. Are you using right ACR ($acrName) and RG ($resourceGroup)?" -ForegroundColor Red
        $valid=$false
    }
    if ($valid -eq $false) {
        exit 1
    }
}

Write-Host "--------------------------------------------------------" -ForegroundColor Yellow
Write-Host " Deploying images on cluster $aksName"  -ForegroundColor Yellow
Write-Host " "  -ForegroundColor Yellow
Write-Host " Additional parameters are:"  -ForegroundColor Yellow
Write-Host " Release Name: $name"  -ForegroundColor Yellow
Write-Host " AKS to use: $aksName in RG $resourceGroup and ACR $acrName"  -ForegroundColor Yellow
Write-Host " Images tag: $tag"  -ForegroundColor Red
Write-Host " --------------------------------------------------------" 

$acrLogin=$(az acr show -n $acrName -g $resourceGroup | ConvertFrom-Json).loginServer
$aksHost=$(az aks show -n $aksName -g $resourceGroup | ConvertFrom-Json).addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName

Write-Host "acr login server is $acrLogin" -ForegroundColor Yellow
Write-Host "aksHost is $aksHost" -ForegroundColor Yellow

validate

pushd helm

Write-Host "Deploying charts $charts" -ForegroundColor Yellow

if ($charts.Contains("pr") -or  $charts.Equals("*")) {
    Write-Host "Products chart - pr" -ForegroundColor Yellow
    helm install --name $name-product -f $valuesFile --set az.productvisitsurl=$afHost --set ingress.hosts={$aksHost} --set image.repository=$acrLogin/product.api --set image.tag=$tag  products-api
}

if ($charts.Contains("cp") -or  $charts.Equals("*")) {
    Write-Host "Coupons chart - cp" -ForegroundColor Yellow
    helm install --name $name-coupon -f $valuesFile --set ingress.hosts={$aksHost} --set image.repository=$acrLogin/coupon.api --set image.tag=$tag coupons-api
}

if ($charts.Contains("pf") -or  $charts.Equals("*")) {
    Write-Host "Profile chart - pf " -ForegroundColor Yellow
    helm install --name $name-profile -f $valuesFile --set ingress.hosts={$aksHost} --set image.repository=$acrLogin/profile.api --set image.tag=$tag profiles-api
}

if ($charts.Contains("pp") -or  $charts.Equals("*")) {
    Write-Host "Popular products chart - pp" -ForegroundColor Yellow
    helm install --name $name-popular-product -f $valuesFile --set ingress.hosts={$aksHost} --set image.repository=$acrLogin/popular-product.api --set image.tag=$tag --set initImage.repository=$acrLogin/popular-product-seed.api  --set initImage.tag=$tag popular-products-api 
}

if ($charts.Contains("st") -or  $charts.Equals("*")) {
    Write-Host "Stock -st" -ForegroundColor Yellow
    helm  install --name $name-stock -f $valuesFile --set ingress.hosts={$aksHost} --set image.repository=$acrLogin/stock.api --set image.tag=$tag stock-api
}

if ($charts.Contains("ic") -or  $charts.Equals("*")) {
    Write-Host "Image Classifier -ic" -ForegroundColor Yellow
    helm  install --name $name-image-classifier -f $valuesFile --set ingress.hosts={$aksHost} --set image.repository=$acrLogin/image-classifier.api --set image.tag=$tag image-classifier-api
}

if ($charts.Contains("ct") -or  $charts.Equals("*")) {
    Write-Host "Cart (Basket) -ct" -ForegroundColor Yellow
    helm  install --name $name-cart -f $valuesFile --set ingress.hosts={$aksHost} --set image.repository=$acrLogin/cart.api --set image.tag=$tag cart-api
}

if ($charts.Contains("mgw") -or  $charts.Equals("*")) {
    Write-Host "mobilebff -mgw" -ForegroundColor Yellow 
    helm  install --name $name-mobilebff -f $valuesFile --set ingress.hosts={$aksHost} --set image.repository=$acrLogin/mobileapigw --set image.tag=$tag mobilebff
}

if ($charts.Contains("wgw") -or  $charts.Equals("*")) {
    Write-Host "webbff -wgw" -ForegroundColor Yellow
    helm  install --name $name-webbff -f $valuesFile --set ingress.hosts={$aksHost} --set image.repository=$acrLogin/webapigw --set image.tag=$tag webbff
}

popd

Write-Host "Tailwind traders deployed on AKS" -ForegroundColor Yellow