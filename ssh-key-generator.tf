resource "random_integer" "key_suffix" {
  min = 1
  max = 1000000

  count = var.instance_number
}
resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits = 4096

  count = var.instance_number
}

resource "aws_key_pair" "public_key" {
  key_name = "terraform-generated-key-${random_integer.key_suffix[count.index].result}"
  public_key = tls_private_key.generated[count.index].public_key_openssh

  count = var.instance_number
}

resource "local_sensitive_file" "private_key" {
  content = tls_private_key.generated[count.index].private_key_pem
  filename = "/ansible-share/ssh-keys/terraform-${aws_instance.server[count.index].id}.pem"
  file_permission = "0400"

  count = var.instance_number
}