<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.8.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >=2.30.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >=2.8.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >=2.30.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_ingress_v1.argocd_server_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_namespace.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ARN of the ACM certificate for the ArgoCD Ingress / ALB | `string` | `null` | no |
| <a name="input_argocd_irsa_role_arn"></a> [argocd\_irsa\_role\_arn](#input\_argocd\_irsa\_role\_arn) | ARN of the IAM role for ArgoCD service account | `string` | `null` | no |
| <a name="input_argocd_values_file_path"></a> [argocd\_values\_file\_path](#input\_argocd\_values\_file\_path) | Values for ArgoCD Helm chart from root project directory. | `string` | `"argocd_values.yaml"` | no |
| <a name="input_argocd_version"></a> [argocd\_version](#input\_argocd\_version) | Version of ArgoCD to deploy | `string` | `"8.0.17"` | no |
| <a name="input_ca_cert_file"></a> [ca\_cert\_file](#input\_ca\_cert\_file) | Path to the CA certificate file. | `string` | `""` | no |
| <a name="input_create_argocd"></a> [create\_argocd](#input\_create\_argocd) | Create ArgoCD | `bool` | `true` | no |
| <a name="input_directory_path"></a> [directory\_path](#input\_directory\_path) | The path to the directory containing the values.yaml file. | `string` | `"files"` | no |
| <a name="input_namespace_argocd"></a> [namespace\_argocd](#input\_namespace\_argocd) | Namespace for ArgoCD | `string` | `"argocd"` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | The AWS SSL security policy for the ALB HTTPS listener. | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
