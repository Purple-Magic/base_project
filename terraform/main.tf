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
    onepassword = {
      source = "1Password/onepassword"
    }
  }
}

locals {
  hostname_app_name = replace(lower(var.app_name), "/[^a-z0-9-]/", "-")
  droplet_name      = var.environment == "production" ? local.hostname_app_name : "${local.hostname_app_name}-${var.environment}"
  subdomain         = var.environment == "production" ? local.hostname_app_name : "${var.environment}.${local.hostname_app_name}"
  onepassword_vault = "${var.onepassword_vault}_${var.environment}"
}

provider "onepassword" {}

data "onepassword_vault" "terraform" {
  name = local.onepassword_vault
}

ephemeral "onepassword_item" "digitalocean" {
  vault = data.onepassword_vault.terraform.uuid
  title = var.onepassword_digitalocean_item
}

ephemeral "onepassword_item" "cloudflare" {
  vault = data.onepassword_vault.terraform.uuid
  title = var.onepassword_cloudflare_item
}

data "onepassword_item" "domain" {
  vault = data.onepassword_vault.terraform.uuid
  title = var.onepassword_domain_item
}

provider "digitalocean" {
  token = ephemeral.onepassword_item.digitalocean.credential
}

provider "cloudflare" {
  api_token = ephemeral.onepassword_item.cloudflare.credential
}

resource "digitalocean_droplet" "kamal_app" {
  name   = local.droplet_name
  region = var.region
  size   = var.size
  image  = "ubuntu-24-04-x64"

  ssh_keys = [var.ssh_key_identifier]
  tags     = ["kamal", var.app_name, var.environment]

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
  name = data.onepassword_item.domain.password
}

resource "cloudflare_record" "base_project_subdomain" {
  zone_id = data.cloudflare_zone.primary.id
  name    = local.subdomain
  content = digitalocean_droplet.kamal_app.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = true
}

output "main_host_ip" {
  value = digitalocean_droplet.kamal_app.ipv4_address
}

output "droplet_id" {
  value = tostring(digitalocean_droplet.kamal_app.id)
}

output "env_snippet" {
  value = <<EOT
MAIN_HOST=${digitalocean_droplet.kamal_app.ipv4_address}
DB_HOST=${digitalocean_droplet.kamal_app.ipv4_address}
EOT
}

output "subdomain_url" {
  value = nonsensitive("${local.subdomain}.${data.onepassword_item.domain.password}")
}

resource "null_resource" "wait_for_ssh" {
  provisioner "local-exec" {
    command = "./wait_for_ssh.sh ${digitalocean_droplet.kamal_app.ipv4_address} 22 ${digitalocean_droplet.kamal_app.id}"
  }

  depends_on = [digitalocean_droplet.kamal_app]
}
