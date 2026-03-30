data "talos_machine_configuration" "workers" {
  cluster_name       = var.talos_config.cluster_name
  machine_type       = "worker"
  cluster_endpoint   = "https://${var.talos_config.control_planes[var.talos_config.bootstrap_node]}:6443"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.talos_config.talos_kubernetes_version
}

resource "talos_machine_configuration_apply" "workers" {
  for_each                    = var.talos_config.workers
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.workers.machine_configuration
  node                        = each.value
  config_patches              = [var.talos_patch]
}
