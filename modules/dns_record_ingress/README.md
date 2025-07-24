<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster where the service is running. | `string` | n/a | yes |
| <a name="input_hosted_zone_name"></a> [hosted\_zone\_name](#input\_hosted\_zone\_name) | The name of the hosted zone where the DNS record will be created. | `string` | n/a | yes |
| <a name="input_ingress_name"></a> [ingress\_name](#input\_ingress\_name) | The ingress name for the DNS record. | `string` | n/a | yes |
| <a name="input_record_type"></a> [record\_type](#input\_record\_type) | The type of DNS record to create (e.g., A, CNAME, etc.). | `string` | `"A"` | no |
| <a name="input_server_namespace"></a> [server\_namespace](#input\_server\_namespace) | The namespace of the server for the DNS record. | `string` | n/a | yes |
| <a name="input_subdomain_name"></a> [subdomain\_name](#input\_subdomain\_name) | The subdomain name for the DNS record. | `string` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | The TTL (Time to Live) for the DNS record. | `number` | `10080` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_dns_name"></a> [load\_balancer\_dns\_name](#output\_load\_balancer\_dns\_name) | The direct DNS name of the Application Load Balancer. |
| <a name="output_service_url"></a> [service\_url](#output\_service\_url) | The URL to access the service. |
<!-- END_TF_DOCS -->
