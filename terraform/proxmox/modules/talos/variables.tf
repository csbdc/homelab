variable "talos_config" {
  type = object({
    cluster_name             = string
    talos_kubernetes_version = string
    bootstrap_node           = string
    control_planes           = map(string)
    workers                  = map(string)
  })
}

variable "talos_patch" {
  type = string
}