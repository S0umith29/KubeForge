resource "proxmox_virtual_environment_vm" "worker1" {
  name = "worker1"
  description = "Ubuntu server"
  vm_id = 202
  node_name = "proxmox"

  agent {
    enabled = true
  }

  clone {
    vm_id = 100
    full = true
  }

  cpu {
  cores = 2
  sockets = 2
  type = "host"
  }

  memory {
    dedicated = 4096
  }

  vga {
    type = "serial0"
    memory = 16
  }

  network_device {
    bridge = "vmbr0"
    model = "virtio"
  }

  disk {
    datastore_id = "local-lvm"
    interface = "scsi0"
    size = 50
  }

  initialization {
    ip_config {
      ipv4 {
        address = "WORKER1_IP"
        gateway = "GATEWAY_ADDRESS"
      }
    }
    dns {
      servers = ["DNS_SERVERS"]
    }

    user_data_file_id = proxmox_virtual_environment_file.worker1cloudinit_user_data.id
    #meta_data_file_id = proxmox_virtual_environement_file.k3
  }

  operating_system {
    type = "l26"
  }

  on_boot = true

}


resource "proxmox_virtual_environment_vm" "worker2" {
  name = "worker2"
  description = "Ubuntu server"
  vm_id = 203
  node_name = "proxmox"

  agent {
    enabled = true
  }

  clone {
    vm_id = 100
    full = true
  }

  cpu {
  cores = 2
  sockets = 2
  type = "host"
  }

  memory {
    dedicated = 4096
  }

  vga {
    type = "serial0"
    memory = 16
  }

  network_device {
    bridge = "vmbr0"
    model = "virtio"
  }

  disk {
    datastore_id = "local-lvm"
    interface = "scsi0"
    size = 50
  }

  initialization {
    ip_config {
      ipv4 {
        address = "WORKER2_IP"
        gateway = "GATEWAY_ADDRESS"
      }
    }
    dns {
      servers = ["DNS_SERVERS"]
    }

    user_data_file_id = proxmox_virtual_environment_file.worker2cloudinit_user_data.id
    #meta_data_file_id = proxmox_virtual_environement_file.k3
  }

  operating_system {
    type = "l26"
  }

  on_boot = true

}
