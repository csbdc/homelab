variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox endpoint."
  default     = ""
  nullable    = false
}

variable "proxmox_username" {
  type        = string
  description = "Proxmox Username."
  default     = ""
  nullable    = false
}

variable "proxmox_password" {
  type        = string
  description = "Proxmox user password."
  default     = ""
  nullable    = false
}

variable "hashed_user_password" {
  type        = string
  description = "Hashed user password created with mkpasswd."
}
