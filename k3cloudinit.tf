resource "proxmox_virtual_environment_file" "k3cloudinit_user_data" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "proxmox"
  source_raw {
    file_name = "k3cloudinit-user-data.yml"
    data      = <<EOF
#cloud-config
hostname: control-node
packages:
  - qemu-guest-agent
  - curl
users:
  - name: soumith
    ssh-authorized-keys:
      - YOUR_SSH_PUBLIC_KEY
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash

runcmd:
  - echo "Cloud-Init started" > /root/cloud-init-start.log
  - systemctl enable qemu-guest-agent || echo "Failed to enable qemu-guest-agent" >> /root/cloud-init-error.log
  - systemctl start qemu-guest-agent || echo "Failed to start qemu-guest-agent" >> /root/cloud-init-error.log
  - curl -sfL https://get.k3s.io | sh -
  - systemctl enable k3s || echo "Failed to enable k3s"
  - systemctl start k3s || echo "Failed to start k3s"
  - echo "Waiting for k3s to start..." && sleep 20
  - kubectl get nodes
  - sudo cat /var/lib/rancher/k3s/server/node-token > /root/k3s-token
  - echo "Cloud-Init completed" > /root/cloud-init.log

write_files:
  - path: /root/.bashrc
    content: |
      alias k='kubectl'
    append: true

EOF
  }
}
