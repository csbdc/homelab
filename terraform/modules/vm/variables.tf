variable "node_count" {
  default  = 0
  type     = number
  nullable = false
}

variable "vm_prefix" {
  type     = string
  default  = ""
  nullable = false
}

variable "target_node" {
  type     = string
  default  = ""
  nullable = false
}

variable "memory" {
  type     = number
  default  = 2048
  nullable = false
}

variable "cores" {
  type     = number
  default  = 2
  nullable = false
}

variable "import_image_url" {
  type     = string
  nullable = false
  default  = ""
}

variable "import_image_filename" {
  type     = string
  nullable = false
  default  = ""
}