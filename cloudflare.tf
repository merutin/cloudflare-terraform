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

# Create a record
locals {
  ips = ["192.0.2.1", "192.0.2.2"]
}

resource "cloudflare_zone" "zone" {
  account_id = var.account_id
  zone       = "merutin.com"
}

resource "cloudflare_zone_dnssec" "example" {
  zone_id = cloudflare_zone.zone.id
}

resource "cloudflare_record" "example" {
  zone_id = cloudflare_zone.zone.id
  name    = "terraform"
  type    = "A"
  ttl     = 1
  proxied = var.proxied

  for_each = toset(local.ips)
  value    = each.value
}

resource "cloudflare_record" "example_root" {
  zone_id = cloudflare_zone.zone.id
  name    = "@"
  value   = "192.0.2.2"
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "txt" {
  zone_id = cloudflare_zone.zone.id
  name    = "terraform.jp"
  value   = "google-site-verification=hogehgoe"
  ttl     = 300
  type    = "TXT"
}

variable "ips" {
  default = ["192.168.1.1", "192.168.1.2", "192.168.1.3"]
}

resource "cloudflare_record" "loop" {
  zone_id = cloudflare_zone.zone.id
  name    = "terraform.loop.jp"
  ttl     = 300
  type    = "A"

  for_each = toset(var.ips)
  value    = each.value
}

resource "cloudflare_ruleset" "cache_settings_example" {
  zone_id     = cloudflare_zone.zone.id
  name        = "set cache settings"
  description = "set cache settings for the request"
  kind        = "zone"
  phase       = "http_request_cache_settings"

  rules {
    action = "set_cache_settings"
    action_parameters {
      edge_ttl {
        mode    = "override_origin"
        default = 60
        status_code_ttl {
          status_code = 200
          value       = 50
        }
        status_code_ttl {
          status_code_range {
            from = 201
            to   = 300
          }
          value = 30
        }
      }
      browser_ttl {
        mode = "respect_origin"
      }
      serve_stale {
        disable_stale_while_updating = true
      }
      respect_strong_etags       = true
      origin_error_page_passthru = false
    }
    expression  = "(http.host eq \"example.host.com\")"
    description = "set cache settings rule"
    enabled     = true
  }
}
