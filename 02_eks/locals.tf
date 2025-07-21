locals {
  prefix = "gitops"
  critical_addon_taints = [
    {
      key    = "CriticalAddonsOnly"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  ]

  critical_addon_tolerations_yaml = yamlencode([
    {
      key      = "CriticalAddonsOnly"
      operator = "Exists"
      effect   = "NO_SCHEDULE"
    }
  ])

  critical_addon_tolerations_json = [
    {
      key      = "CriticalAddonsOnly"
      operator = "Exists"
      effect   = "NoSchedule"
    }
  ]

}
