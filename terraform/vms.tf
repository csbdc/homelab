module "talos_vms" {
  source = "./modules/vm"
  count  = length(var.pve_nodes)

  target_node = var.pve_nodes[count.index]
  vm_prefix   = "vm-talos"
  node_count  = var.talos_nodes_per_pve_node

  import_image_url      = "https://factory.talos.dev/image/10f9392d7091b30abf573524649756e5bc894f653af525836e9ab0297f301fc2/v1.12.4/metal-amd64.qcow2"
  import_image_filename = "talos.qcow2"

  cores  = 4
  memory = 8192
}

locals {
  control_planes = flatten([module.talos_vms[*].control_plane])
  workers        = flatten([module.talos_vms[*].workers])
}

output "control_planes" {
  value = local.control_planes
}

output "workers" {
  value = local.workers
}