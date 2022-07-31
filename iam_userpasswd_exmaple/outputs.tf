output "password" {
  value = aws_iam_user_login_profile.example.encrypted_password
}

output "keybase_password_decrypt_command" {
  # https://stackoverflow.com/questions/36565256/set-the-aws-console-password-for-iam-user-with-terraform
  description = "Command to decrypt the Keybase encrypted password. Returns empty string if pgp_key is not from keybase"
  value       = local.keybase_password_decrypt_command
}