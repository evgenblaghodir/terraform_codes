provider "aws" {

}



resource "aws_instance" "my_WebServer" {
  ami                    = "ami-0c64dd618a49aeee8" # Amazon Linux
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_WebServer_FW.id]


  tags = {
    Name  = "Webserver"
    Owner = "Yevhen"
  }
  depends_on = [aws_instance.my_DBServer, aws_instance.my_AppServer]
}
resource "aws_instance" "my_AppServer" {
  ami                    = "ami-0c64dd618a49aeee8" # Amazon Linux
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_WebServer_FW.id]

  tags = {
    Name  = "Application server"
    Owner = "Yevhen"
  }
  depends_on = [aws_instance.my_DBServer]

}
resource "aws_instance" "my_DBServer" {
  ami                    = "ami-0c64dd618a49aeee8" # Amazon Linux
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_WebServer_FW.id]


  tags = {
    Name  = "Database server"
    Owner = "Yevhen"
  }
}
resource "aws_security_group" "my_WebServer_FW" {
  name = "Dynamic FW rule"

  #  vpc_id      = "${aws_vpc.main.id}"

  dynamic "ingress" {
    for_each = ["80", "443", "22"]
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
