provider "aws" {

}


resource "null_resource" "command1" {
  provisioner "local-exec" {
    command = "echo Terraform Start: $(date) >> log.txt"

  }
}

resource "null_resource" "command2" {
  provisioner "local-exec" {
    command = "ping -c 5 www.google.com"
  }
  depends_on = [null_resource.command1]
}

/*resource "null_resource" "command3" {
  provisioner "local-exec" {
    command = /usr/bin/python2.7 -c print('Hello from python command3')"
  }

}*/

resource "null_resource" "command4" {
  provisioner "local-exec" {
    command     = "print('Hello from python command4')"
    interpreter = ["python", "-c"]
  }

}

resource "null_resource" "command5" {
  provisioner "local-exec" {
    command = "echo $AWS_DEFAULT_REGION >> names.txt"

  }
}

resource "aws_instance" "myserver" {
  ami           = "ami-0d5d9d301c853a04a"
  instance_type = "t3.micro"
  provisioner "local-exec" {
    command = "echo Hello from AWS Instance Creations!"

  }

}

resource "null_resource" "command6" {
  provisioner "local-exec" {
    command = "echo Terraform END: $(data) >> log.txt"

  }
  depends_on = [null_resource.command1, null_resource.command2, null_resource.command4, null_resource.command5, aws_instance.myserver]
}
