locals {
  talos_pve_nodes = ["pve-1fdq713", "pve-dh16933", "pve-j0zk2w2"]
}

resource "proxmox_virtual_environment_download_file" "talos_img" {
  for_each     = toset(local.talos_pve_nodes)
  content_type = "import"
  datastore_id = "local"
  node_name    = each.key
  url          = "https://factory.talos.dev/image/10f9392d7091b30abf573524649756e5bc894f653af525836e9ab0297f301fc2/v1.12.4/metal-amd64.qcow2"
  file_name    = "talos.qcow2"
}

module "control_planes" {
  for_each = toset(local.talos_pve_nodes)
  source   = "./modules/vm"
  vm_spec = {
    name          = "talos"
    random_suffix = true
    pve_node      = each.key
    disks = [{
      datastore_id = "local-lvm"
      img          = proxmox_virtual_environment_download_file.talos_img[each.key].id
      interface    = "scsi0"
      size         = 45
  }] }
}

module "workers" {
  for_each = toset(local.talos_pve_nodes)
  source   = "./modules/vm"
  vm_spec = {
    name          = "talos"
    random_suffix = true
    pve_node      = each.key
    cpu = {
      cores = 4
    }
    memory = {
      dedicated = 10240
    }
    disks = [{
      datastore_id = "local-lvm"
      img          = proxmox_virtual_environment_download_file.talos_img[each.key].id
      interface    = "scsi0"
      size         = 45
  }] }
}

locals {
  talos_patch = <<EOF
machine:
cluster:
EOF
}

locals {
  nodes = {
    control_planes = {
      for node in local.talos_pve_nodes : node => module.control_planes[node].ipv4_address
    }
    workers = {
      for node in local.talos_pve_nodes : node => module.workers[node].ipv4_address
    }
  }
}

module "talos" {
  depends_on = [module.control_planes, module.workers]
  source     = "./modules/talos"
  talos_config = {
    cluster_name             = "csbdc-cluster"
    bootstrap_node           = local.talos_pve_nodes[0]
    control_planes           = local.nodes["control_planes"]
    workers                  = local.nodes["workers"]
    talos_kubernetes_version = "1.35.0"
  }
  talos_patch = local.talos_patch
}

output "cluster_node_ips" {
  value = local.nodes
}

resource "local_file" "kubeconfig" {
  content  = module.talos.kubeconfig
  filename = "/Users/cbxon/.kube/config"
}