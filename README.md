# eks-terraform
Deploy a full EKS cluster with Terraform

## Configuration

NOTE: This full configuration utilizes the [Terraform http provider](https://www.terraform.io/docs/providers/http/index.html) to call out to icanhazip.com to determine your local workstation external IP for easily configuring EC2 Security Group access to the Kubernetes master servers. Feel free to replace this as necessary.


## How to use this example:

```bash
git clone git@github.com:WesleyCharlesBlake/eks-terraform.git
cd eks-terraform
```

> You can create a file called terraform.tfvars in the project root, to place your variables if you would like to overide the defaults.

Accepted variables:

1. `aws-region` | us-east-1 or us-west-2
2. `cluster-name` | string

eg:

```bash
cat terraform.tfvars
aws-region = "us-west-2"
cluster-name = "eks-demo"
```

### Terraform

You need to run the following commands to create the resources with Terraform:

```bash
terraform init
terraform plan
terraform apply
```

### Setup kubectl

Setup your `KUBECONFIG`

```bash
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