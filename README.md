# eks-terraform
Deploy a full EKS cluster with Terraform

## What does resources are created:

1. VPC
2. Internet Gateway (IGW)
3. Public and Private Subnets
4. Security Groups, Route Tables and Route Table Associations
5. IAM roles, instance profiles and policies
6. An EKS Cluster
7. Autoscaling group and Launch Configuration
8. Worker Nodes in a private Subnet
9. The ConfigMap required to register Nodes with EKS
10. KUBECONFIG file to authenticate kubectl using the heptio authenticator aws binary

## How to use this example:

```bash
git clone git@github.com:WesleyCharlesBlake/eks-terraform.git
cd eks-terraform
```

## Configuration

You can configure you config with the following variables:

|          Name                      |                       Description                               |                         Default                          |
|------------------------------------|-----------------------------------------------------------------|----------------------------------------------------------|
| `cluster-name`                     | The name of your EKS Cluster                                    | `my-cluster`                                             |
| `aws-region`                       | The AWS Region to deploy EKS                                    | `us-west-2`                                              |
| `node-instance-type`               | Worker Node EC2 instance type                                   | `m4.large`                                               |
| `desired-capacity`                 | Autoscaling Desired node capacity                               | `2`                                                      |
| `max-size`                         | Autoscaling Maximum node capacity                               | `5`                                                      |
| `min-size`                         | Autoscaling Minimum node capacity                               | `1`                                                      |

> You can create a file called terraform.tfvars in the project root, to place your variables if you would like to over-ride the defaults.

Accepted variables:

1. `aws-region` | us-east-1 or us-west-2
2. `cluster-name` | string

eg:

```bash
# file: terraform.tfvars
aws-region = "us-west-2"
cluster-name = "your-eks-cluster-name"
```

Or you can can pass in the variables to terraform as shown:

```bash
terraform plan --var "cluster-name=your-eks-cluster-name"
```

## Remote Terraform Module

You can use this module from the Terraform registry as a remote source:

```bash
module "module" {
  source  = "WesleyCharlesBlake/module/eks"
  version = "1.0.0"

  cluster-name       = "${var.cluster-name}"
  aws-region         = "${var.aws-region}"
  node-instance-type = "${var.node-instance-type}"
  desired-capacity   = "${var.desired-capacity}"
  max-size           = "${var.max-size}"
  min-size           = "${var.min-size}"
}
```

You can also reference this module in your Terraform config remotely as shown below:

```bash
#file: main.tf
module "eks" {
  source = "github.com/WesleyCharlesBlake/eks-terraform//modules/eks"
  cluster-name = "${var.cluster-name}"
  aws-region   = "${var.aws-region}"
}
```

### Terraform

You need to run the following commands to create the resources with Terraform:

```bash
terraform init
terraform plan
terraform apply
```

> TIP: you should save the plan state `terraform plan -out eks-state` or even better yet, setup [remote storage](https://www.terraform.io/docs/state/remote.html) for Terraform state. You can store state in an [S3 backend](https://www.terraform.io/docs/backends/types/s3.html), with locking via DynamoDB

### Setup kubectl

Setup your `KUBECONFIG`

```bash
terraform output kubeconfig > ~/.kube/eks-cluster
export KUBECONFIG=~/.kube/eks-cluster
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