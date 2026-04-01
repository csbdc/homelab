variable "proxmox_endpoint" {
  type     = string
  default  = ""
  nullable = false
}

variable "proxmox_username" {
  type     = string
  default  = ""
  nullable = false
}

variable "proxmox_password" {
  type     = string
  default  = ""
  nullable = false
}

variable "hashed_user_password" {
  type = string
}
