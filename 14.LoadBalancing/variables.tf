variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "alb_tg_name" {
  description = "The name of the tagret group of ALB"
  type        = string
  default     = "socialnetwork-lb-tg"
}

variable "instance_security_group_name" {
  description = "The name of the security group for the EC2 Instances"
  type        = string
  default     = "socialnetwork-instance-sg"
}

variable "alb_security_group_name" {
  description = "The name of the security group for the ALB"
  type        = string
  default     = "socialnetwork-lb-sg"
}
