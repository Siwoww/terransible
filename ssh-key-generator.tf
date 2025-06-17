resource "random_integer" "key_suffix" {
  min = 1
  max = 1000000
}
resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "public_key" {
  key_name = "terraform-generated-key-${random_integer.key_suffix.result}"
  public_key = tls_private_key.generated.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  content = tls_private_key.generated.private_key_pem
  filename = "../../.ssh-keys/terraform-${aws_instance.server.id}"
  file_permission = "0400"
}