provider "aws" {

}

resource "random_string" "gen_pwd" {
  length           = 12
  special          = true
  override_special = "!#$&"

}

resource "aws_ssm_parameter" "gen_pwd" {
  name        = "/prod/mysql"
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.gen_pwd.result

}


data "aws_ssm_parameter" "my_rds_password" {
  name       = "/prod/mysql"
  depends_on = [aws_ssm_parameter.gen_pwd]
}

output " my_rds_password" {
  value = data.aws_ssm_parameter.my_rds_password.value
}
