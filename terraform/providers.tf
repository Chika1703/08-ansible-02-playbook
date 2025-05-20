terraform {
  required_providers {
    twc = {
      source  = "tf.timeweb.cloud/timeweb-cloud/timeweb-cloud"
      version = ">= 1.4.5"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.1.0"
    }
  }
  required_version = ">= 1.11.3"
}

provider "twc" {
  token = var.twc_token
}

provider "local" {}
