provider "aws" {

}

resource "aws_instance" "my_Ubuntu" {
  count         = 1
  ami           = "ami-0d5d9d301c853a04a"
  instance_type = "t3.micro"

  tags = {
    Name    = "my_Ubuntu_server"
    Owner   = "Yevhen"
    Project = "Terraform Lesson"
  }
}


resource "aws_instance" "my_Amazon" {
  count         = 1
  ami           = "ami-0c64dd618a49aeee8"
  instance_type = "t3.small"

  tags = {
    Name    = "my_Amazon_server"
    Owner   = "Yevhen"
    Project = "Terraform Lesson"
  }
}
