variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "ssh_fingerprint" {
  description = "Your SSH key fingerprint in DigitalOcean"
  type        = string
}

variable "region" {
  description = "Region slug (e.g. fra1, nyc3)"
  default     = "fra1"
}

variable "size" {
  description = "Droplet size"
  default     = "s-1vcpu-1gb"
}

variable "app_name" {
  description = "App name (used for tags)"
  default     = "base_project"
}

variable "cloudflare_email" {
  description = "Cloudflare account email"
  type        = string
}

variable "cloudflare_api_key" {
  description = "Cloudflare API Key (Global API Key)"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Domain to manage in Cloudflare"
  type        = string
}

