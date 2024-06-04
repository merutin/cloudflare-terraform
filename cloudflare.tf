# Configure the Cloudflare provider using the required_providers stanza
# required with Terraform 0.13 and beyond. You may optionally use version
# directive to prevent breaking changes occurring unannounced.
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.api_token
}

resource "cloudflare_zone_dnssec" "example" {
  zone_id = var.zone_id
}

# Create a record
resource "cloudflare_record" "example" {
  zone_id = var.zone_id
  name    = "terraform"
  value   = "192.0.2.1"
  type    = "A"
  ttl     = 1
  proxied = var.proxied
}

resource "cloudflare_record" "example2" {
  zone_id = var.zone_id
  name    = "terraform"
  value   = "192.0.2.2"
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "txt" {
  zone_id = var.zone_id
  name    = "terraform.jp"
  value   = "google-site-verification=hogehgoe"
  ttl     = 300
  type    = "TXT"
}

variable "ips" {
  default = ["192.168.1.1", "192.168.1.2", "192.168.1.3"]
}

resource "cloudflare_record" "loop" {
  zone_id  = var.zone_id
  name     = "terraform.loop.jp"
  ttl      = 300
  type     = "A"

  for_each = toset(var.ips)
  value    = each.value
}