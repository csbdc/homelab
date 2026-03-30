locals {
  ipv4_address = flatten([
    for group in proxmox_virtual_environment_vm.vm.ipv4_addresses : [
      for ip in group : ip if length(ip) > 0 && split(".", ip)[0] == "192"
    ]
  ])
}

output "ipv4_address" {
  value = var.vm_spec.agent != false ? local.ipv4_address[0] : "not_set"
}