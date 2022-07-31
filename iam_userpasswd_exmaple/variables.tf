variable "pgp_key" {
  type        = string
  default     = "keybase:username" 
  description = "Provide a base-64 encoded PGP public key, or a keybase username in the form `keybase:username`. Required to encrypt password."
}
