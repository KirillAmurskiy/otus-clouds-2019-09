
variable "gce_ssh_user" {
  type = string
  default = "kirill_amurskiy"
}

variable "gce_ssh_pub_key_file" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}
