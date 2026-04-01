variable "vm_spec" {
  type = object({
    name          = string
    random_suffix = optional(bool, false)
    pve_node      = string
    cpu = optional(object({
      cores   = optional(number, 2)
      sockets = optional(number, 1)
      type    = optional(string, "host")
    }), {})
    agent = optional(bool, true)
    memory = optional(object({
      floating  = optional(number, 0)
      dedicated = optional(number, 2048)
    }), {})
    network_device = optional(object({
      bridge = optional(string, "vmbr0")
      vlan   = optional(number, 0)
    }), {})
    disks = list(object({
      datastore_id = string
      img          = optional(string, null)
      interface    = string
      size         = number
    }))
    cloudinit   = optional(bool, false)
    userdata_id = optional(string, null)
    cdrom = optional(object({
      file_id = optional(string, null)
    }), {})
  })
}
