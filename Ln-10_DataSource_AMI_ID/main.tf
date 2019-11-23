provider "aws" {

}

data "aws_ami" "latest_ubuntu_server" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "my_Ubuntu" {
  count         = 1
  ami           = data.aws_ami.latest_ubuntu_server.id
  instance_type = "t3.micro"

  tags = {
    Name    = "my_Ubuntu_server"
    Owner   = "Yevhen"
    Project = "Terraform Lesson"
  }
}

output "latest_ubuntu_ami_id" {
  value = data.aws_ami.latest_ubuntu_server.id
}
output "latest_ubuntu_ami_name" {
  value = data.aws_ami.latest_ubuntu_server.name
}
