# Outputs
output "karpenter_resources_created" {
  description = "List of Karpenter resources created"
  value       = keys(kubernetes_manifest.karpenter_objects)
}
