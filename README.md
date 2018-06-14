# eks-terraform
Deploy a full EKS cluster with Terraform

## How to use this example:

```bash
git clone git@github.com:WesleyCharlesBlake/eks-terraform.git
cd eks-terraform
```

### Terraform

```bash
terraform init
terraform plan
terraform apply
```

### Authorize worker nodes

Get the config from terraform output, and save it to a yaml file:

```bash
terraform output config-map-aws-auth > config-map-aws-auth.yaml
```

Apply the config map to EKS

```bash
kubectl apply -f config-map-aws-auth.yaml
```

You can verify the worker nodes are joining the cluster

```bash
kubectl get nodes --watch
```

### Cleaning up

You can destroy this cluster entirely by running:

```bash
terraform plan -destroy
terraform destroy  --force
```