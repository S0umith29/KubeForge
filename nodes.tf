variable "k3s_token" {
  type = string
  description = "k3s token for joining worker nodes"
  sensitive = true
}

resource "proxmox_virtual_environment_vm" "control_plane" {
  name = "control-plane"
  description = "Ubuntu server"
  vm_id = 201
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
  
  vga {
    type = "serial0"
    memory = 16
  }

  memory { 
    dedicated = 4096
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
        address = "CONTROL_NODE_IP"
        gateway = "GATEWAY_ADDRESS"
      }
    }
    dns {
      servers = ["DNS_SERVERS"]  
    }

    user_data_file_id = proxmox_virtual_environment_file.k3cloudinit_user_data.id
    #meta_data_file_id = proxmox_virtual_environement_file.k3
  }
  
  operating_system {
    type = "l26"
  }

  on_boot = true
  
}

resource "null_resource" "fetch_k3s_token" {
  depends_on = [proxmox_virtual_environment_vm.control_plane]
  provisioner "local-exec" {
    command = "sleep 60 && ssh -o StrictHostKeyChecking=no soumith@CONTROL_NODE_IP 'sudo cat /root/k3s-token' > k3s-token.txt"
  }
}

resource "null_resource" "fetch_kube_config" {
  depends_on = [proxmox_virtual_environment_vm.control_plane]
  provisioner "local-exec" {
    command = "sleep 10 && ssh -o StrictHostKeyChecking=no soumith@CONTROL_NODE_IP 'sudo cat /etc/rancher/k3s/k3s.yaml' > k3s.yaml"
  }
}
