terraform {
  required_version = "1.5.7"
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
    }
  }
}

resource "talos_machine_secrets" "this" {}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.talos_config.control_planes[var.talos_config.bootstrap_node]
}

data "talos_client_configuration" "this" {
  depends_on           = [talos_cluster_kubeconfig.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  cluster_name         = var.talos_config.cluster_name
  endpoints            = [for k, v in var.talos_config.control_planes : v]
  nodes                = flatten([[for k, v in var.talos_config.control_planes : v], [for k, v in var.talos_config.workers : v]])
}