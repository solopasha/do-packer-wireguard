## Set the variable value in *.tfvars file
variable "do_api_token" {}
variable "droplet_name" {}
variable "region_name" {}
variable "sshkey_name" {}
variable "pvt_key" {}

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
    }
  }
}

## Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_api_token
}

## set name do key
data "digitalocean_ssh_key" "default" {
  name = var.sshkey_name
}

## Snapshot
data "digitalocean_droplet_snapshot" "web-snapshot" {
  name_regex  = "fed10"
  region      = var.region_name
  most_recent = true
}

## Create a new droplet from an existing image
resource "digitalocean_droplet" "web" {
  image = data.digitalocean_droplet_snapshot.web-snapshot.id
  #count = 1
  #name = "${var.droplet_name}-${count.index}"
  name     = var.droplet_name
  region   = var.region_name
  size     = "s-1vcpu-1gb"
  ipv6     = true
  tags     = ["vpn", "test"]
  ssh_keys = [data.digitalocean_ssh_key.default.id]

  connection {
    user        = "root"
    type        = "ssh"
    host        = self.ipv4_address
    private_key = file(var.pvt_key)
  }

  ## Copy file
  provisioner "file" {
    source      = "./scripts/install.sh"
    destination = "/tmp/install.sh"
  }

  ## Run sh
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install.sh",
      "/tmp/install.sh",
    ]
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i ${self.ipv4_address}, --private-key ${var.pvt_key} ../ansible/roles/playbook.yml"

  }
}

resource "digitalocean_firewall" "web" {
  name = "only-22-80-443-and-wg"

  droplet_ids = [digitalocean_droplet.web.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "51820"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "51820"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
## out info
output "droplet_ip_address" {
  value = digitalocean_droplet.web[*].ipv4_address
}
