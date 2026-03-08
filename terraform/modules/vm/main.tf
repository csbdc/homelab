terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "random_string" "vm_suffix" {
  count   = var.node_count
  length  = 5
  upper   = false
  special = false
}

resource "proxmox_virtual_environment_vm" "vm" {
  count     = var.node_count
  node_name = var.target_node
  name      = join("-", [var.vm_prefix, random_string.vm_suffix[count.index].result])

  cpu {
    cores   = var.cores
    sockets = 1
    type    = "host"
  }

  agent {
    enabled = true
  }

  memory {
    dedicated = var.memory
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.img.id
    interface    = "scsi0"
    size = 20
  }
}

resource "proxmox_virtual_environment_download_file" "img" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.target_node
  url          = var.import_image_url
  file_name    = var.import_image_filename
}

locals {
  ipv4_addresses = flatten([
    for group in proxmox_virtual_environment_vm.vm[*].ipv4_addresses : [
      for address in group : [
        for ip in address : ip if length(ip) > 0 && split(".", ip)[0] == "192"
      ]
    ]
  ])
  nodes = [
    for node in proxmox_virtual_environment_vm.vm[*] : {
      name = "${node.name}"
      ips  = flatten([for ip_list in node.ipv4_addresses : [for ip in ip_list : ip if split(".", ip)[0] == "192"]])[0]
    }
  ]
  control_plane = [local.nodes[0].ips]
  workers       = flatten([for worker in local.nodes : worker.ips if worker.name != local.nodes[0].name])
}

output "control_plane" {
  value = local.control_plane
}

output "workers" {
  value = local.workers
}