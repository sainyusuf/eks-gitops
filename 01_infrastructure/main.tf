module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "gitops-vpc"
  cidr = "10.0.0.0/16"

  azs             = var.availibility_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                = "1"
    "karpenter.sh/discovery/shared-service-prod-eks" = "true"
  }
}
