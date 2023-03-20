variable "name" {
  type = string
  default = "network-manager"
}
variable "region" {
  type = string
  default = "ap-northeast-2"
}
variable "ip_pool_cnt" {
  type = number
  description = "must enter an even integer"
}
variable "subnet_ids" {
  type = list(string)
  description = "input [Your Subnet id 1,Your Subnet id 2]"
}
variable "tag_value" {
  type = string
  default = "bastion"
}
variable "vpc_id" {
  type = string
}
variable "instance_type" {
  type = string
  default = "t3.micro"
}
variable "volume_type" {
  type = string
  default = "gp3"
}
variable "volume_size" {
  type = number
  default = 8
}