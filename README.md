# terraform-aws-eks

[![CircleCI](https://circleci.com/gh/WesleyCharlesBlake/terraform-aws-eks.svg?style=svg)](https://circleci.com/gh/WesleyCharlesBlake/terraform-aws-eks)
[![TerraformRefigistry](https://img.shields.io/badge/Terraform%20Registry-v2.0.2-blue.svg)](https://registry.terraform.io/modules/WesleyCharlesBlake/eks/aws/)


Deploy a full AWS EKS cluster with Terraform

## What resources are created

1. VPC
2. Internet Gateway (IGW)
3. Public and Private Subnets
4. Security Groups, Route Tables and Route Table Associations
5. IAM roles, instance profiles and policies
6. An EKS Cluster
7. Autoscaling group and Launch Configuration
8. Worker Nodes in a private Subnet
9. bastion host for ssh access to the VPC
10. The ConfigMap required to register Nodes with EKS
11. KUBECONFIG file to authenticate kubectl using the `aws eks get-token` command. needs awscli version `1.16.156 >`

## Configuration

You can configure you config with the following input variables:

| Name                      | Description                        | Default                                                               |
| ------------------------- | ---------------------------------- | --------------------------------------------------------------------- |
| `cluster-name`            | The name of your EKS Cluster       | `eks-cluster`                                                         |
| `aws-region`              | The AWS Region to deploy EKS       | `us-east-1`                                                           |
| `availability-zones`      | AWS Availability Zones             | `["us-east-1a", "us-east-1b", "us-east-1c"]`                          |
| `k8s-version`             | The desired K8s version to launch  | `1.13`                                                                |
| `node-instance-type`      | Worker Node EC2 instance type      | `m4.large`                                                            |
| `root-block-size`         | Size of the root EBS block device  | `20`                                                                  |
| `desired-capacity`        | Autoscaling Desired node capacity  | `2`                                                                   |
| `max-size`                | Autoscaling Maximum node capacity  | `5`                                                                   |
| `min-size`                | Autoscaling Minimum node capacity  | `1`                                                                   |
| `public-min-size`         | Public Node groups ASG capacity    | `1`                                                                     |
| `public-max-size`         | Public Node groups ASG capacity    | `1`                                                                     |
| `public-desired-capacity` | Public Node groups ASG capacity    | `1`                                                                     |
| `vpc-subnet-cidr`         | Subnet CIDR                        | `10.0.0.0/16`                                                         |
| `private-subnet-cidr`     | Private Subnet CIDR                | `["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]`                     |
| `public-subnet-cidr`      | Public Subnet CIDR                 | `["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]`                 |
| `db-subnet-cidr`          | DB/Spare Subnet CIDR               | `["10.0.192.0/21", "10.0.200.0/21", "10.0.208.0/21"]`                 |
| `eks-cw-logging`          | EKS Logging Components             | `["api", "audit", "authenticator", "controllerManager", "scheduler"]` |
| `ec2-key`                 | EC2 Key Pair for bastion and nodes | `my-key`                                                              |

> You can create a file called terraform.tfvars or copy [variables.tf](https://github.com/WesleyCharlesBlake/terraform-aws-eks/blob/master/variables.tf) into the project root, if you would like to over-ride the defaults.

## How to use this example

```bash
git clone git@github.com:WesleyCharlesBlake/terraform-aws-eks.git
cd terraform-aws-eks
```

## Remote Terraform Module

> **NOTE** use `version = "2.0.0"` with terraform `0.12.x >` and `version = 1.0.4` with terraform `< 0.11x`

Have a look at the [examples](examples) for complete references
You can use this module from the Terraform registry as a remote source:

```terraform
module "eks" {
  source  = "WesleyCharlesBlake/eks/aws"

  aws-region          = "us-east-1"
  availability-zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cluster-name        = "my-cluster"
  k8s-version         = "1.13"
  node-instance-type  = "t3.medium"
  root-block-size     = "40"
  desired-capacity    = "3"
  max-size            = "5"
  min-size            = "1"
  public-min-size     = "0" # setting to 0 will create the launch config etc, but no nodes will deploy"
  public-max-size     = "0"
  public-desired-capacity = "0"
  vpc-subnet-cidr     = "10.0.0.0/16"
  private-subnet-cidr = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  public-subnet-cidr  = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
  db-subnet-cidr      = ["10.0.192.0/21", "10.0.200.0/21", "10.0.208.0/21"]
  eks-cw-logging      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  ec2-key             = "my-key"
}

output "kubeconfig" {
  value = module.eks.kubeconfig
}

output "config-map" {
  value = module.eks.config-map
}

```

**Or** by using variables.tf or a tfvars file:

```terraform
module "eks" {
  source  = "WesleyCharlesBlake/eks/aws"

  aws-region          = var.aws-region
  availability-zones  = var.availability-zones
  cluster-name        = var.cluster-name
  k8s-version         = var.k8s-version
  node-instance-type  = var.node-instance-type
  root-block-size     = var.root-block-size
  desired-capacity    = var.desired-capacity
  max-size            = var.max-size
  min-size            = var.min-size
  public-min-size     = var.public-min-size
  public-max-size     = var.public-max-size
  public-desired-capacity = var.public-desired-capacity
  vpc-subnet-cidr     = var.vpc-subnet-cidr
  private-subnet-cidr = var.private-subnet-cidr
  public-subnet-cidr  = var.public-subnet-cidr
  db-subnet-cidr      = var.db-subnet-cidr
  eks-cw-logging      = var.eks-cw-logging
  ec2-key             = var.ec2-key
}
```

### IAM

The AWS credentials must be associated with a user having at least the following AWS managed IAM policies

* IAMFullAccess
* AutoScalingFullAccess
* AmazonEKSClusterPolicy
* AmazonEKSWorkerNodePolicy
* AmazonVPCFullAccess
* AmazonEKSServicePolicy
* AmazonEKS_CNI_Policy
* AmazonEC2FullAccess

In addition, you will need to create the following managed policies

*EKS*

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": "*"
        }
    ]
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
