module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "gitops-vpc"
  cidr = "10.0.0.0/16"

  azs             = var.availibility_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false

}
