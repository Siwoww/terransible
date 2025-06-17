data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["amazon"]

  filter {
    name = "Name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "server" {
  ami = data.aws_ami.ubuntu.image_id
  instance_type = var.instance_type
}