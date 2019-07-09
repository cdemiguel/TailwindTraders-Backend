Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
Write-Host "Removing RBAC for Tiller" -ForegroundColor Yellow
Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
kubectl -n kube-system delete deployment tiller-deploy
kubectl delete clusterrolebinding tiller-cluster-rule
kubectl -n kube-system delete serviceaccount tiller