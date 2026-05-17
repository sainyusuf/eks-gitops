# Karpenter Configuration Layer
# Deploys NodePools and EC2NodeClass to Karpenter-enabled cluster
# MUST be applied AFTER Karpenter helm chart is installed

# Karpenter NodePool and EC2NodeClass Manifests
locals {
  karpenter_yaml_files = fileset("${path.module}/files/karpenter", "*.yaml")

  karpenter_manifests = {
    for f in local.karpenter_yaml_files :
    f => yamldecode(templatefile(
      "${path.module}/files/karpenter/${f}",
      {
        cluster_name        = data.terraform_remote_state.cluster.outputs.cluster_name
        karpenter_node_role = data.terraform_remote_state.karpenter.outputs.karpenter_node_iam_role_name
    }))
  }
}

resource "kubernetes_manifest" "karpenter_objects" {
  for_each = local.karpenter_manifests

  manifest = each.value

  computed_fields = [
    "metadata.finalizers",
    "metadata.managedFields",
    "metadata.generation",
    "metadata.resourceVersion",
    "metadata.uid",
    "spec.requirements",
    "spec.template.spec.requirements",
    "status"
  ]

  field_manager {
    name            = "terraform"
    force_conflicts = true
  }
}
