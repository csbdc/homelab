terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
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
