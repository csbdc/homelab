resource "helm_release" "fluxcd" {
  depends_on       = [module.talos.kubeconfig]
  create_namespace = true
  chart            = "flux2"
  name             = "fluxcd"
  repository       = "https://fluxcd-community.github.io/helm-charts"
  version          = "v2.18.2"
  namespace        = "flux-system"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

resource "kubernetes_secret_v1" "git_ssh_flux" {
  depends_on = [helm_release.fluxcd]
  metadata {
    name      = "git-ssh-flux"
    namespace = "flux-system"
  }
  data = {
    "identity"     = tls_private_key.ssh_key.private_key_openssh
    "identity.pub" = tls_private_key.ssh_key.public_key_openssh
    "known_hosts"  = "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
  }
  type = "kubernetes.io/generic"
}


resource "helm_release" "flux2_sync" {
  depends_on       = [helm_release.fluxcd]
  create_namespace = true
  chart            = "flux2-sync"
  name             = "homelab-github-flux-sync"
  namespace        = "flux-system"
  repository       = "https://fluxcd-community.github.io/helm-charts"
  version          = "v1.14.4"
  set = [
    {
      name  = "gitRepository.spec.url"
      value = "ssh://git@github.com/csbdc/homelab.git"
    },
    {
      name  = "gitRepository.spec.secretRef.name"
      value = "git-ssh-flux"
    },
    {
      name  = "gitRepository.spec.ref.branch"
      value = "main"
    },
    {
      name  = "kustomization.spec.path"
      value = "manifests/"
    }
  ]
}
