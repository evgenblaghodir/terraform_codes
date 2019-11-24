/*
Provisin HA Web in any Region in Default VPC
Create:
   - Security group for Web-server
   - Launch Configuration with Auto AMI lookup
   - Auto Scaling Group using 2 AZ
   - Classic Load Balancer in 2 AZ
*/

provider "aws" {

}

data "aws_availability_zones" "available_az" {}

data "aws_ami" "amzon_AMI" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
#-----------------------------------------------------------
#Security_group
## FIREWALL RULE FOR WebServer e.g. SECURITY GROUP
resource "aws_security_group" "my_WebServer_FW" {
  name = "Dynamic FW rule"

  #  vpc_id      = "${aws_vpc.main.id}"
  #INCOMING TRAFFIC
  dynamic "ingress" {
    for_each = ["80", "443"]
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
  tags = {
    Name  = "Dynamic FW rule"
    Owner = "Yevhen"
  }
}

### -----------Launch configuration
resource "aws_launch_configuration" "web" {
  #name            = "WebServer-Highly-available-LC"
  name_prefix     = "WebServer-Highly-available-LC-"
  image_id        = data.aws_ami.amzon_AMI.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.my_WebServer_FW.id]
  user_data       = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "Web" {
  name                 = "ASG-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.web_elb.name]
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  dynamic "tag" {
    for_each = {
      Name   = "WebServer in ASG"
      Owner  = "Yevhen Blahodyr"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_elb" "web_elb" {
  name               = "WebServer-HA-ELB"
  availability_zones = [data.aws_availability_zones.available_az.names[0], data.aws_availability_zones.available_az.names[1]]
  security_groups    = [aws_security_group.my_WebServer_FW.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = {
    Name = "WebServer-HA-ELB"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_az.names[0]

}
resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available_az.names[1]

}
output "web_lb_url" {
  value = aws_elb.web_elb.dns_name
}
