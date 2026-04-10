variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["production", "staging"], var.environment)
    error_message = "environment must be either production or staging."
  }
}

variable "ssh_key_identifier" {
  description = "DigitalOcean SSH key identifier resolved from the configured 1Password SSH key name"
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

variable "onepassword_vault" {
  description = "1Password vault name prefix that stores Terraform provider credentials"
  type        = string
  default     = "base_project"
}

variable "onepassword_digitalocean_item" {
  description = "1Password item title for the DigitalOcean API credential"
  type        = string
  default     = "DigitalOcean Terraform"
}

variable "onepassword_cloudflare_item" {
  description = "1Password item title for the Cloudflare API credential"
  type        = string
  default     = "Cloudflare Terraform"
}

variable "onepassword_domain_item" {
  description = "1Password item title for the domain value"
  type        = string
  default     = "Terraform Domain"
}

variable "onepassword_main_host_item" {
  description = "1Password item title for the MAIN_HOST value"
  type        = string
  default     = "MAIN_HOST"
}

variable "onepassword_host_item" {
  description = "1Password item title for the HOST value"
  type        = string
  default     = "HOST"
}

variable "onepassword_ssh_key_name_item" {
  description = "1Password item title for the DigitalOcean SSH key name value"
  type        = string
  default     = "Terraform SSH Key Name"
}
