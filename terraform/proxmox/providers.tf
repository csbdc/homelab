terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0-beta.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = true
  username = var.proxmox_username
  password = var.proxmox_password

  ssh {
    agent    = true
    username = "root"
  }
}

provider "kubernetes" {
  client_key             = base64decode(yamldecode(module.talos.kubeconfig)["users"][0]["user"]["client-key-data"])
  client_certificate     = base64decode(yamldecode(module.talos.kubeconfig)["users"][0]["user"]["client-certificate-data"])
  cluster_ca_certificate = base64decode(yamldecode(module.talos.kubeconfig)["clusters"][0]["cluster"]["certificate-authority-data"])
  host                   = yamldecode(module.talos.kubeconfig)["clusters"][0]["cluster"]["server"]
}

provider "helm" {
  kubernetes = {
    client_key             = base64decode(yamldecode(module.talos.kubeconfig)["users"][0]["user"]["client-key-data"])
    client_certificate     = base64decode(yamldecode(module.talos.kubeconfig)["users"][0]["user"]["client-certificate-data"])
    cluster_ca_certificate = base64decode(yamldecode(module.talos.kubeconfig)["clusters"][0]["cluster"]["certificate-authority-data"])
    host                   = yamldecode(module.talos.kubeconfig)["clusters"][0]["cluster"]["server"]
  }
}
