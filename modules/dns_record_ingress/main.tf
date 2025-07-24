data "aws_route53_zone" "this" {
  name         = var.hosted_zone_name
  private_zone = false
}


data "aws_lb" "this" {
  tags = {
    "elbv2.k8s.aws/cluster" = var.cluster_name
    "ingress.k8s.aws/stack" = local.ingress_tag
  }
}

# This record will point your service domain name to the discovered ALB.
resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "${var.subdomain_name}.${data.aws_route53_zone.this.name}"
  type    = var.record_type

  # An ALIAS record is a special AWS record type that points to another AWS resource.
  alias {
    # The DNS name of the AWS resource to point to (the ALB)
    name = data.aws_lb.this.dns_name
    # The canonical hosted zone ID of the AWS resource (the ALB)
    zone_id = data.aws_lb.this.zone_id
    # Set to true to enable health checking for the alias
    evaluate_target_health = true
  }
}
