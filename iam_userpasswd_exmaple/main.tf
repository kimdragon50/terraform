
provider "aws" {
  region = "ap-northeast-2"
}


resource "aws_iam_user" "example" {
  name          = "example"
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user_login_profile" "example" {
  user    = aws_iam_user.example.name
  pgp_key = var.pgp_key
}

locals {
  encrypted_password               = join("", aws_iam_user_login_profile.example.*.encrypted_password)
  pgp_key_is_keybase               = length(regexall("keybase:", var.pgp_key)) > 0 ? true : false
  keybase_password_decrypt_command = local.pgp_key_is_keybase ? templatefile("templates/keybase_password_decrypt_command.sh", { encrypted_password = local.encrypted_password }) : ""
}


output "password" {
  value = aws_iam_user_login_profile.example.encrypted_password
}

output "keybase_password_decrypt_command" {
  # https://stackoverflow.com/questions/36565256/set-the-aws-console-password-for-iam-user-with-terraform
  description = "Command to decrypt the Keybase encrypted password. Returns empty string if pgp_key is not from keybase"
  value       = local.keybase_password_decrypt_command
}
