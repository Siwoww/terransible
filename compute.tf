data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["amazon"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.main-sg.id]
  subnet_id = aws_subnet.public_subnet[0].id
  key_name = aws_key_pair.public_key[count.index].key_name
  #user_data = templatefile("./main-userdata.tpl", {new_hostname = "server-${count.index + 1}"})
  
  root_block_device {
    volume_size = var.main_vol_size
  }

  tags = {
    Name = "server-${count.index + 1}"
    inventory_path = var.inventory_path
    #server_private_key = local_sensitive_file.private_key.filename
  }

  provisioner "local-exec" {
    command = "echo '${self.public_ip} ansible_ssh_private_key_file=${var.private_key_path}-${self.id}.pem' >> ${var.inventory_path}"
  }

  provisioner "local-exec" {
    when = destroy
    command = "sed -i '/^[0-9]/d' ${self.tags.inventory_path}"
  }

  count = var.instance_number
}

/*resource "null_resource" "grafana_install" {
  depends_on = [ aws_instance.server ]
  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.inventory_path} "
  }
}*/