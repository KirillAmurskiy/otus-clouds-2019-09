variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "pg_admin_password"{
  type = string
  default = "admin"
}

variable "gce_ssh_user" {
  type = string
  default = "kirill_amurskiy"
}

variable "gce_ssh_pub_key_file" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}
