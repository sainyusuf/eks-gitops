output "service_url" {
  description = "The URL to access the service."
  value       = "https://${aws_route53_record.this.fqdn}"
}

output "load_balancer_dns_name" {
  description = "The direct DNS name of the Application Load Balancer."
  value       = data.aws_lb.this.dns_name
}
