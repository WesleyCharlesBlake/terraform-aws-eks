# terraform-aws-eks

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
9. The ConfigMap required to register Nodes with EKS
10. KUBECONFIG file to authenticate kubectl using the heptio authenticator aws binary

## Configuration

You can configure you config with the following input variables:

| Name                 | Description                       | Default       |
|----------------------|-----------------------------------|---------------|
| `cluster-name`       | The name of your EKS Cluster      | `my-cluster`  |
| `aws-region`         | The AWS Region to deploy EKS      | `us-west-2`   |
| `k8s-version`        | The desired K8s version to launch | `1.11`        |
| `node-instance-type` | Worker Node EC2 instance type     | `m4.large`    |
| `desired-capacity`   | Autoscaling Desired node capacity | `2`           |
| `max-size`           | Autoscaling Maximum node capacity | `5`           |
| `min-size`           | Autoscaling Minimum node capacity | `1`           |
| `vpc-subnet-cidr`    | Subnet CIDR                       | `10.0.0.0/16` |


> You can create a file called terraform.tfvars in the project root, to place your variables if you would like to over-ride the defaults.

## How to use this example

```bash
git clone git@github.com:WesleyCharlesBlake/terraform-aws-eks.git
cd terraform-aws-eks
```

## Remote Terraform Module

You can use this module from the Terraform registry as a remote source:

```bash
module "module" {
  source  = "WesleyCharlesBlake/eks/aws"
  version = "1.0.5"

  cluster-name       = "${var.cluster-name}"
  aws-region         = "${var.aws-region}"
  k8s-version        = "${var.k8s-version}"
  node-instance-type = "${var.node-instance-type}"
  desired-capacity   = "${var.desired-capacity}"
  max-size           = "${var.max-size}"
  min-size           = "${var.min-size}"
  vpc-subnet-cidr    = "${var.vpc-subnet-cidr}"
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

```
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
