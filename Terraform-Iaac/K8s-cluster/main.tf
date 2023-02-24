resource "aws_eks_cluster" "Cluster" {
  name = "ITI-Cluster"
  role_arn = aws_iam_role.EKS-cluster-Role.arn
  vpc_config {
    subnet_ids = var.eks-node-subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs = [ "0.0.0.0/0" ]
  }
    depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}

resource "aws_iam_role" "EKS-cluster-Role" {
      name = "eks-cluster-role"
      assume_role_policy = <<POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "eks.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
    POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.EKS-cluster-Role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.EKS-cluster-Role.name
}


resource "aws_eks_addon" "kubeproxy-addon" {
  cluster_name = aws_eks_cluster.Cluster.name
  addon_name = "kube-proxy"
}

resource "aws_eks_addon" "coredns-addon" {
  cluster_name = aws_eks_cluster.Cluster.name
  addon_name = "coredns"

}

resource "aws_eks_addon" "vpc-cni-addon" {
  cluster_name = aws_eks_cluster.Cluster.name
  addon_name = "vpc-cni"
}

resource "aws_launch_template" "launch_template_eks_group_node" {
  instance_type = "t3.small"
  key_name = "ansible"
  block_device_mappings {
     device_name = "/dev/sda1"
    ebs {
      volume_size = 15
    }
  }
  
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.Cluster.name
  node_group_name = "Testing-node"
  node_role_arn   = aws_iam_role.eks-node-group.arn
  subnet_ids      = var.eks-node-subnet_ids
  #disk_size = 10
  launch_template {
    id      = aws_launch_template.launch_template_eks_group_node.id
    version = "1"
  }

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "eks-node-group" {
  name = "eks-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-group.name
}