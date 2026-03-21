terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

resource "digitalocean_droplet" "kamal_app" {
  name       = "base_project"
  region     = var.region
  size       = var.size
  image      = "ubuntu-24-04-x64"

  ssh_keys   = [var.ssh_fingerprint]
  tags       = ["kamal", var.app_name]

  backups    = false
  ipv6       = true
  monitoring = true

  #user_data = <<-EOF
  #  #!/bin/bash
  #  mkdir -p /root/files
  #  chown 1000:1000 /root/files
  #  chmod 755 /root/files
  #EOF
}

data "cloudflare_zone" "primary" {
  name = var.domain
}

# Create an A record for base_project.purple-magic.com
resource "cloudflare_record" "base_project_subdomain" {
  zone_id = data.cloudflare_zone.primary.id
  name    = "base_project"
  content = digitalocean_droplet.kamal_app.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = true
}

output "main_host_ip" {
  value = digitalocean_droplet.kamal_app.ipv4_address
}

output "env_snippet" {
  value = <<EOT
MAIN_HOST=${digitalocean_droplet.kamal_app.ipv4_address}
DB_HOST=${digitalocean_droplet.kamal_app.ipv4_address}
EOT
}

output "subdomain_url" {
  value = "base_project.${var.domain}"
}

resource "null_resource" "wait_for_ssh" {
  provisioner "local-exec" {
    command = "./wait_for_ssh.sh ${digitalocean_droplet.kamal_app.ipv4_address} 22 ${digitalocean_droplet.kamal_app.id}"
  }

  depends_on = [digitalocean_droplet.kamal_app]
}
