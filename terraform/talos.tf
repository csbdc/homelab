locals {
  talos_patches = var.talos_patch_file != null ? file(var.talos_patch_file) : yamlencode({
    machine = {
      install = {
        disk = "/dev/sdd"
      }
    }
  })
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "control_plane" {
  cluster_name       = var.talos_cluster_name
  machine_type       = "controlplane"
  cluster_endpoint   = "https://${local.control_planes[0]}:6443"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.talos_kubernetes_version
}

resource "talos_machine_configuration_apply" "control_plane" {
  for_each                    = toset(local.control_planes)
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane.machine_configuration
  node                        = each.value
  config_patches              = [local.talos_patches]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.control_plane
  ]
  node                 = local.control_planes[0]
  client_configuration = talos_machine_secrets.this.client_configuration
}

data "talos_machine_configuration" "worker" {
  cluster_name       = var.talos_cluster_name
  machine_type       = "worker"
  cluster_endpoint   = "https://${local.control_planes[0]}:6443"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.talos_kubernetes_version
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = toset(local.workers)
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value
  config_patches              = [local.talos_patches]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.control_planes[0]
}

resource "local_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = var.kubeconfig_filepath
}