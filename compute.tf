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
  key_name = aws_key_pair.public_key.key_name
  
  root_block_device {
    volume_size = var.main_vol_size
  }

  tags = {
    Name = "server-${count.index + 1}"
  }

  count = 1
}