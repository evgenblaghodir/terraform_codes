

provider "aws" {
  region = var.region
}

data "aws_ami" "latest_amzon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_eip" "my_static_ip" {
  instance = aws_instance.my_aws_amazon_linux.id
  tags     = merge(var.common_tags, { Name = "${var.common_tags["Enviroment"]} ServerIP" })
}

resource "aws_instance" "my_aws_amazon_linux" {
  #count                  = 1
  ami                    = data.aws_ami.latest_amzon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_WebServer_FW.id]
  monitoring             = var.enable_detailed_monitoring

  /*tags = {
    Name    = "my_Ubuntu_server"
    Owner   = "Yevhen"
    Project = "Terraform Lesson"
    Region  = var.region
  } */
  #tags = var.common_tags

  tags = merge(var.common_tags, { Region = var.region })
}

## FIREWALL RULE FOR WebServer e.g. SECURITY GROUP
resource "aws_security_group" "my_WebServer_FW" {
  name = "Dynamic FW rule"

  #  vpc_id      = "${aws_vpc.main.id}"

  dynamic "ingress" {
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  #OUT TRAFFIC
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.common_tags, { Name = "${var.common_tags["Enviroment"]} Dynamic FW rule" })

}
