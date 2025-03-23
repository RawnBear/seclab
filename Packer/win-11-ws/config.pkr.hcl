packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "hostname" {
  type    = string
  default = "seclab-win-11-ws"
}

locals {
  username          = vault("/seclab/data/seclab/", "seclab_user")
  password          = vault("/seclab/data/seclab/", "seclab_windows_password")
  proxmox_api_id    = vault("/seclab/data/seclab/", "proxmox_api_id")
  proxmox_api_token = vault("/seclab/data/seclab/", "proxmox_api_token")
}

variable "proxmox_node" {
  type    = string
  default = "proxmox"
}

source "proxmox-iso" "seclab-win-11-ws" {
  proxmox_url  = "https://${var.proxmox_node}:8006/api2/json"
  node         = "${var.proxmox_node}"
  username     = "${local.proxmox_api_id}"
  token        = "${local.proxmox_api_token}"
  
  boot_iso {
    iso_file     = "local:iso/Win-11-Enterprise.iso"
    iso_checksum = "sha256:373baba19031bd864ef8ea0288f63caf13f89341315a488a9318ef8ee4793286"
  }

  /*skip_export             = true*/
  communicator             = "ssh"
  ssh_username             = "${local.username}"
  ssh_password             = "${local.password}"
  ssh_timeout              = "30m"
  qemu_agent               = true
  cores                    = 4
  memory                   = 8192
  vm_name                  = "seclab-win-11-ws"
  template_description     = "Base Seclab Windows 11 Workstation"
  insecure_skip_tls_verify = true
  bios                     = "ovmf"
  boot                     = "order=ide0;ide2"
  boot_wait                = "2s"
  boot_command             = [
    "<space><space><space><space><space><space><space><space><space><space><space><space><space><space><space><space><space><space><space><space><space><space>"
  ]

  tpm_config {
    tpm_storage_pool       = "external-zfs"
    tpm_version            = "v2.0"
  }

  efi_config {
    efi_storage_pool       = "external-zfs"
    pre_enrolled_keys      = true
  }

  additional_iso_files {
    type         = "sata"
    index        = 1
    iso_file     = "local:iso/Autounattend-win-11-ws.iso"
    iso_checksum = "sha256:213f58292eb41f33cf1530c11a7fa1535e630ebd1c42fdcdb97ab1e876023c81"
  }
  additional_iso_files {
    type         = "sata"
    index        = 0
    iso_file     = "local:iso/virtio-win.iso"
    iso_checksum = "sha256:57b0f6dc8dc92dc2ae8621f8b1bfbd8a873de9bedc788c4c4b305ea28acc77cd"
    unmount      = true
  }

  network_adapters {
    bridge = "vmbr2"
  }

  disks {
    type         = "ide"
    disk_size    = "60G"
    storage_pool = "external-zfs"
  }
  scsi_controller = "virtio-scsi-single"

}

build {
  sources = ["sources.proxmox-iso.seclab-win-11-ws"]
  provisioner "windows-shell" {
    inline = ["ipconfig"]
  }
}