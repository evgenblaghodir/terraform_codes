variable "region" {
  default     = "us-east-2"
  type        = string
  description = "Please Enter AWS Region to deploy server"
}

variable "instance_type" {
  description = "Enter instance size"
  type        = string
  default     = "t3.micro"
}

variable "allow_ports" {
  description = "List of Allow ports for SG"
  type        = list
  default     = ["80", "433", "22"]
}

variable "enable_detailed_monitoring" {
  type = bool
  #default = "true"
}

variable "common_tags" {
  description = "Common tags apply to all resources"
  type        = map
  default = {
    Owner      = "Yevhen Blahodyr"
    Project    = "Alpha"
    Enviroment = "TESTENV"
  }
}
