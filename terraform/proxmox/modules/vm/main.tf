terraform {
  required_version = "1.5.7"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
}

resource "random_string" "vm_suffix" {
  count   = var.vm_spec.random_suffix == true ? 1 : 0
  length  = 5
  upper   = false
  special = false
}

resource "proxmox_virtual_environment_vm" "vm" {
  node_name = var.vm_spec.pve_node
  name      = var.vm_spec.random_suffix == true ? join("-", [var.vm_spec.name, random_string.vm_suffix[0].result]) : var.vm_spec.name

  cpu {
    cores   = var.vm_spec.cpu.cores
    sockets = var.vm_spec.cpu.sockets
    type    = var.vm_spec.cpu.type
  }

  agent { enabled = var.vm_spec.agent }

  memory {
    floating  = var.vm_spec.memory.floating
    dedicated = var.vm_spec.memory.dedicated
  }

  network_device {
    bridge  = var.vm_spec.network_device.bridge
    vlan_id = var.vm_spec.network_device.vlan
  }

  dynamic "disk" {
    for_each = var.vm_spec.disks
    content {
      datastore_id = disk.value.datastore_id
      import_from  = disk.value.img != null ? disk.value.img : null
      interface    = disk.value.interface
      size         = disk.value.size
    }
  }

  dynamic "initialization" {
    for_each = var.vm_spec.cloudinit == true ? ["cloud-init"] : []
    content {
      ip_config {
        ipv4 {
          address = "dhcp"
        }
      }
      interface = "ide2"

      user_data_file_id = var.vm_spec.userdata_id != null ? var.vm_spec.userdata_id : null
    }
  }

  dynamic "cdrom" {
    for_each = var.vm_spec.cdrom.file_id != null ? ["use-cdrom"] : []
    content {
      file_id = var.vm_spec.cdrom.file_id
    }
  }
}
