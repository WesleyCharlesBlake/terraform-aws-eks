# eks-terraform
Deploy a full EKS cluster with Terraform

## Configuration

NOTE: This full configuration utilizes the [Terraform http provider](https://www.terraform.io/docs/providers/http/index.html) to call out to icanhazip.com to determine your local workstation external IP for easily configuring EC2 Security Group access to the Kubernetes master servers. Feel free to replace this as necessary.


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

### Setup kubectl

Setup your `KUBECONFIG`
```
terraform output kubeconfig ~/.kube/eks-cluster
export KUBECONFIG ~/.kube/eks-cluster
```

### Authorize worker nodes

Get the config from terraform output, and save it to a yaml file:

```bash
terraform output config-map > config-map-aws-auth.yaml
```

Apply the config map to EKS:

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