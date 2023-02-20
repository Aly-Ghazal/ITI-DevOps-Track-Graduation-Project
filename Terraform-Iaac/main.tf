module "myNetwork" {
  source                    = "./VPC"
  VPC-cidr                  = "10.0.0.0/16"
  VPC-name                  = "Terraform-Project-Network"
  publicSubnets-cidr        = ["10.0.0.0/24", "10.0.2.0/24"]
  Subnet-Availability-zones = ["eu-central-1a", "eu-central-1b"]
  publicSubnets-tag-names   = ["publicsubnet-01", "publicsubnet-02"]
  privateSubnets-cidr       = ["10.0.1.0/24", "10.0.3.0/24"]
  privateSubnets-tag-names  = ["privatesubnet-01", "privatesubnet-02"]
}

module "Eks-Ckuster" {
  source = "./K8s-cluster"
  eks-cluster-subnets-id    = module.myNetwork.publicSubnets-ids
  eks-node-subnet_ids       = module.myNetwork.PrivateSubnets-ids
}