Write-Host "Destroying Kubernetes resources in namespace: demo..."

# Delete Ingress
kubectl delete ingress nginx-ingress -n demo

# Delete Service
kubectl delete svc nginx-service -n demo

# Delete Deployment
kubectl delete deployment nginx-deployment -n demo

# Delete ConfigMap
kubectl delete configmap app-config -n demo

# Destroy Terraform-managed resources
Write-Host "Destroying Terraform infrastructure..."
terraform destroy -auto-approve

Write-Host "Infrastructure successfully destroyed!"