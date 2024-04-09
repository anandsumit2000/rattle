resource "aws_eks_cluster" "eks" {
  name    = var.cluster_name
  version = var.eks_version
  vpc_config {
    subnet_ids = [
      data.aws_subnet.private_1.id,
      data.aws_subnet.private_2.id,
      data.aws_subnet.public_1.id,
      data.aws_subnet.public_2.id
    ]
  }
  role_arn   = aws_iam_role.eks_role.arn
  depends_on = [aws_iam_role_policy_attachment.eks-role-AmazonEKSClusterPolicy]
}

# resource "aws_eks_addon" "coredns" {
#   cluster_name = aws_eks_cluster.eks.name
#   addon_name   = "coredns"
# }

# # Define kube-proxy addon
# resource "aws_eks_addon" "kube_proxy" {
#   cluster_name = aws_eks_cluster.eks.name
#   addon_name   = "kube-proxy"
# }

# # Define Amazon VPC CNI addon
# resource "aws_eks_addon" "vpc_cni" {
#   cluster_name = aws_eks_cluster.eks.name
#   addon_name   = "vpc-cni"
# }