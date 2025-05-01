resource "null_resource" "name" {

  provisioner "local-exec" {
    command = "echo Hello, World!"
  }

}
