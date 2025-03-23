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
  default = "seclab-win-server-2022"
}

variable "proxmox_node" {
  type    = string
  default = "proxmox"
}


locals {
  username          = vault("/seclab/data/seclab/", "seclab_user")
  password          = vault("/seclab/data/seclab/", "seclab_windows_password")
  proxmox_api_id    = vault("/seclab/data/seclab/", "proxmox_api_id")
  proxmox_api_token = vault("/seclab/data/seclab/", "proxmox_api_token")
}


source "proxmox-iso" "seclab-win-server-2022" {
  proxmox_url              = "https://${var.proxmox_node}:8006/api2/json"
  node                     = "${var.proxmox_node}"
  username                 = "${local.proxmox_api_id}"
  token                    = "${local.proxmox_api_token}"
  insecure_skip_tls_verify = true
  communicator             = "ssh"
  ssh_username             = "${local.username}"
  ssh_password             = "${local.password}"
  ssh_timeout              = "30m"
  qemu_agent               = true
  bios                     = "ovmf"
  cores                    = 4
  memory                   = 8192
  vm_name                  = "seclab-win-server-2022"
  template_description     = "Base Seclab Windows Server 2022"

  boot_iso {
    iso_file                 = "local:iso/Win-Server-2022.iso"
    iso_checksum             = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
  }

  tpm_config {
    tpm_storage_pool   = "external-zfs"
    tpm_version        = "v2.0"
  } 

  efi_config {
    efi_storage_pool       = "external-zfs"
    pre_enrolled_keys      = true
  }

  additional_iso_files {
    type         = "sata"
    index        = 0
    iso_file     = "local:iso/Autounattend-win-server-2022.iso"
    iso_checksum = "sha256:587ab7b1e3f0f8b1608ec961a718e2d2bf0628fdefb189c6e5d5feced44bd461"
    unmount      = true
  }

  additional_iso_files {
    type         = "sata"
    index        = 1
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

  boot_wait = "5s"
  boot_command = [
    "<del><enter><tab><enter><enter>"
  ]

}


build {
  sources = ["sources.proxmox-iso.seclab-win-server-2022"]
  provisioner "windows-shell" {
    inline = [
      "ipconfig",
    ]
  }

}
