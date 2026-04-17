output "kubeconfig" {
  description = "kubeconfig of created talos cluster."
  value = talos_cluster_kubeconfig.this.kubeconfig_raw
}
