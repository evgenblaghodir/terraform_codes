provider "aws" {

}

data "aws_ami" "latest_ubuntu_server" {
  owners      = [""]
  most_recent = true
  fileter {
    name  = "name"
    value = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}
