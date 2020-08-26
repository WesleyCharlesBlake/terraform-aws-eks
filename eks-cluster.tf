# EKS Cluster Resources

resource "aws_eks_cluster" "eks" {
  name = var.cluster-name

  version = var.k8s-version

  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    security_group_ids = [data.aws_security_group.cluster.id]
    subnet_ids         = data.aws_subnet_ids.private.ids
  }

  enabled_cluster_log_types = var.eks-cw-logging

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,
  ]
}
