locals {
  dns_pve_nodes = ["pve-1fdq713", "pve-dh16933"]
  nfs_pve_nodes = ["pve-j0zk2w2"]
}

resource "proxmox_virtual_environment_download_file" "alpine_img" {
  for_each     = toset(flatten([local.dns_pve_nodes, local.nfs_pve_nodes]))
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key
  url          = "https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/x86/alpine-virt-3.23.3-x86.iso"
  file_name    = "alpine.iso"
}

module "dns" {
  for_each = toset(local.dns_pve_nodes)
  source   = "./modules/vm"
  vm_spec = {
    name          = "dns"
    random_suffix = true
    pve_node      = each.key
    agent         = false
    disks = [{
      datastore_id = "local-lvm"
      interface    = "scsi0"
      size         = 10
    }]
    cdrom = {
      file_id = proxmox_virtual_environment_download_file.alpine_img[each.key].id
  } }
}

module "nfs" {
  for_each = toset(local.nfs_pve_nodes)
  source   = "./modules/vm"
  vm_spec = {
    name     = "nfs"
    pve_node = each.key
    agent    = false
    disks = [{
      datastore_id = "local-lvm"
      interface    = "scsi0"
      size         = 10
    }]
    cdrom = {
      file_id = proxmox_virtual_environment_download_file.alpine_img[each.key].id
  } }
}