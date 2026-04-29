output "kubeconfig" {
  description = "kubeconfig of created talos cluster."
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
}

output "talosconfig" {
  description = "talosconfig of created talos cluster."
  value       = data.talos_client_configuration.this.talos_config
}