# Karpenter Resource Discovery Tags
# Karpenter uses these tags to discover subnets and security groups
# for launching EC2 instances. Tag format is critical:
# karpenter.sh/discovery/<cluster-name> = "true"

# Tag private subnets for Karpenter discovery
resource "aws_ec2_tag" "subnet_discovery" {
  for_each    = toset(data.terraform_remote_state.infra.outputs.shared_vpc_id_prod_private_subnet_ids)
  resource_id = each.value
  key         = "karpenter.sh/discovery/${data.terraform_remote_state.cluster.outputs.cluster_name}"
  value       = "true"
}

# Tag node security group for Karpenter discovery
resource "aws_ec2_tag" "security_group_discovery" {
  resource_id = data.terraform_remote_state.cluster.outputs.node_security_group_id
  key         = "karpenter.sh/discovery/${data.terraform_remote_state.cluster.outputs.cluster_name}"
  value       = "true"
}
