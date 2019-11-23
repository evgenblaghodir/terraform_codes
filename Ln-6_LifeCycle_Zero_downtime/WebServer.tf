#
# Build WebServer
#

provider "aws" {

}

resource "aws_eip" "my_static_ip" {
  instance = aws_instance.my_WebServer.id
}

resource "aws_instance" "my_WebServer" {
  ami                    = "ami-0c64dd618a49aeee8" # Amazon Linux
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_WebServer_FW.id]
  user_data = templatefile("user_data.sh.tpl", {
    f_name = "Yevhen",
    l_name = "Blahodyr",
    names  = ["Mike", "John", "Petya", "Donald", "Kolya", "Petro", "Katya"]
  })

  tags = {
    Name  = "WebServer build"
    Owner = "Yevhen"
  }

  lifecycle {
    create_before_destroy = true
    #prevent_destroy = true
    #ignore_changes = ["ami", "user_data"] # ignore changes in resources ami and user_data
  }

}

## FIREWALL RULE FOR WebServer e.g. SECURITY GROUP
resource "aws_security_group" "my_WebServer_FW" {
  name        = "WebServer FW rule"
  description = "My First Security group"
  #  vpc_id      = "${aws_vpc.main.id}"

  #INCOMING TRAFFIC
  ingress {
    # TLS (change to whatever ports you need)
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"] # add a CIDR block here
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port = 433
    to_port   = 433
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"] # add a CIDR block here
  }
  #OUT TRAFFIC
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "WebServer FW rule"
    Owner = "Yevhen"
  }
}
