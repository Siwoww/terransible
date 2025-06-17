output "ssh-connect" {
  value = "ssh -i ${local_file.private_key.filename} ubuntu@${aws_instance.server.public_ip}"
}