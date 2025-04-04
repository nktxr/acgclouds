terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
  }
}

provider "null" {}

resource "null_resource" "hello" {
  provisioner "local-exec" {
    command = "echo Hello, World!"
  }
}