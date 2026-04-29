variable "talos_config" {
  description = "Config map to build Talos cluster."
  type = object({
    cluster_name             = string
    talos_kubernetes_version = string
    bootstrap_node           = string
    control_planes           = map(string)
    workers                  = map(string)
  })
}

variable "talos_patch" {
  description = "Talos patch file in yaml format."
  type        = string
}