variable "talos_nodes_per_pve_node" {
  type     = number
  default  = 0
  nullable = false
}

variable "pve_nodes" {
  type     = list(string)
  default  = []
  nullable = false
}

variable "kubeconfig_filepath" {
  type     = string
  default  = ""
  nullable = false
}

variable "talos_kubernetes_version" {
  type     = string
  default  = "1.35.0"
  nullable = false
}
variable "talos_cluster_name" {
  type     = string
  default  = ""
  nullable = false
}

variable "proxmox_endpoint" {
  type     = string
  default  = ""
  nullable = false
}

variable "proxmox_username" {
  type     = string
  default  = ""
  nullable = false
}

variable "proxmox_password" {
  type     = string
  default  = ""
  nullable = false
}

variable "talos_patch_file" {
  type     = string
  nullable = true
  default  = null
}