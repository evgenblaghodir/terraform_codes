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

data "aws_instances" "aws_ec2_instance_id" {

  filter {
    name   = "tag:Name"
    values = ["Jump_Server in ASG"]

  }
  depends_on = [aws_autoscaling_group.jmp_srv_asg]
}

resource "aws_eip" "static_IP_JumpSRV" {
  instance = "${data.aws_instances.aws_ec2_instance_id.ids[0]}"

}

resource "aws_security_group" "my_Bastion_FW_rule" {
  name = "Dynamic FW rule"

  #  vpc_id      = "${aws_vpc.main.id}"
  #INCOMING TRAFFIC
  dynamic "ingress" {
    for_each = ["22"]
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
resource "aws_launch_configuration" "jmp_srv_lc" {
  #name            = "WebServer-Highly-available-LC"
  name_prefix                 = "jmp_srv_lc-Highly-available-LC-"
  image_id                    = data.aws_ami.amzon_AMI.id
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.my_Bastion_FW_rule.id]
  associate_public_ip_address = true



}

resource "aws_autoscaling_group" "jmp_srv_asg" {
  name                 = "ASG-${aws_launch_configuration.jmp_srv_lc.name}"
  launch_configuration = aws_launch_configuration.jmp_srv_lc.name
  min_size             = 1
  max_size             = 1
  min_elb_capacity     = 1
  #health_check_type    = "ELB"
  #load_balancers       = [aws_elb.web_elb.name]
  vpc_zone_identifier = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  dynamic "tag" {
    for_each = {
      Name   = "Jump_Server in ASG"
      Owner  = "Yevhen Blahodyr"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
/*resource "aws_lb" "test" {
  name               = "jumpsrv-lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.public.*.id}"]

  enable_deletion_protection = true
  subnet_mapping {
    subnet_id     = "${aws_subnet.example1.id}"
    allocation_id = "${aws_eip.example1.id}"
  }

  subnet_mapping {
    subnet_id     = "${aws_subnet.example2.id}"
    allocation_id = "${aws_eip.example2.id}"
  }

  tags = {
    Environment = "test"
  }
}*/

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_az.names[0]

}
resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available_az.names[1]

}



output "aws_ec2_instance_id" {
  #value = join(data.aws_instances.aws_ec2_instance_id.id)
  #count = "${length(data.aws_instances.aws_ec2_instance_id.ids)}"
  value = "${data.aws_instances.aws_ec2_instance_id.ids[0]}"
}
