locals {
  dns_pve_nodes = ["pve-1fdq713", "pve-dh16933"]
  nfs_pve_nodes = ["pve-j0zk2w2"]
}

resource "proxmox_virtual_environment_download_file" "alpine_img" {
  for_each     = toset(flatten([local.dns_pve_nodes, local.nfs_pve_nodes]))
  content_type = "import"
  datastore_id = "local"
  node_name    = each.key
  url          = "https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/cloud/generic_alpine-3.23.3-x86_64-bios-cloudinit-r0.qcow2"
  file_name    = "alpine_3-23-3_x86_64.qcow2"
}

data "local_file" "ssh_public_key" {
  filename = "../../id_ed25519.pub"
}

resource "proxmox_virtual_environment_file" "user_data_alpine_cloud_config" {
  for_each     = toset(flatten([local.dns_pve_nodes, local.nfs_pve_nodes]))
  content_type = "snippets"
  datastore_id = "local"
  node_name    = each.key

  source_raw {
    data = <<-EOF
#cloud-config
users:
  - name: cbxon
    groups: wheel
    lock_passwd: false
    passwd: "${var.hashed_user_password}"
    ssh_authorized_keys:
      - "${trimspace(data.local_file.ssh_public_key.content)}"
    doas:
      - "permit nopass cbxon as root"
      - "permit persist cbxon as root"

chpasswd:
  expire: false

ssh_pwauth: true

package_update: true
packages:
  - qemu-guest-agent
  - openssh

# Configure doas and services
runcmd:
  # Allow wheel group to use doas without password
  - echo "permit nopass :wheel" > /etc/doas.d/doas.conf

  # Enable and start services (OpenRC)
  - rc-update add sshd
  - rc-update add qemu-guest-agent
  - rc-service sshd start
  - rc-service qemu-guest-agent start
    EOF

    file_name = "user-data-alpine-cloud-config.yaml"
  }
}

module "dns" {
  depends_on = [proxmox_virtual_environment_file.user_data_alpine_cloud_config]
  for_each   = toset(local.dns_pve_nodes)
  source     = "./modules/vm"
  vm_spec = {
    name          = "dns"
    random_suffix = true
    pve_node      = each.key
    cloudinit     = true
    userdata_id   = proxmox_virtual_environment_file.user_data_alpine_cloud_config[each.key].id
    disks = [{
      datastore_id = "local-lvm"
      img          = proxmox_virtual_environment_download_file.alpine_img[each.key].id
      interface    = "virtio0"
      size         = 10
    }]
  }
}

output "dns_node_ips" {
  description = "IP of DNS servers created."
  value = {
    for node in local.dns_pve_nodes : node => module.dns[node].ipv4_address
  }
}

module "nfs" {
  for_each = toset(local.nfs_pve_nodes)
  source   = "./modules/vm"
  vm_spec = {
    name        = "nfs"
    pve_node    = each.key
    cloudinit   = true
    userdata_id = proxmox_virtual_environment_file.user_data_alpine_cloud_config[each.key].id
    disks = [{
      datastore_id = "local-lvm"
      img          = proxmox_virtual_environment_download_file.alpine_img[each.key].id
      interface    = "scsi0"
      size         = 10
      }, {
      datastore_id = "nfs-lvm"
      interface    = "scsi1"
      size         = 500
      }
    ]
  }
}

output "nfs_node_ips" {
  description = "IP of NFS server created."
  value = {
    for node in local.nfs_pve_nodes : node => module.nfs[node].ipv4_address
  }
}
