################################################################################
# ACM For GitOps
################################################################################

module "acm_certificate_argocd" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.2.0"

  domain_name               = var.gitops_domain_name
  zone_id                   = data.aws_route53_zone.this.zone_id
  subject_alternative_names = ["*.tukang-awan.com"]
  validation_method         = "DNS"
  wait_for_validation       = true
  dns_ttl                   = 172800

  tags = {
    Name = var.gitops_domain_name
  }

}
