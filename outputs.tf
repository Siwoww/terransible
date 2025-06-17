output "ssh-connect" {
  value = "ssh -i ${local_sensitive_file.private_key.filename} ubuntu@${aws_instance.server[0].public_ip}"
}