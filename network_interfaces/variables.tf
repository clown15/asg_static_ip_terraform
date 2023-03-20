variable "name" {
  type = string
  default = "network-manager"
}
variable "role" {
  type = list(string)
  default = [ "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" ]
}
variable "region" {
  type = string
  default = "ap-northeast-2"
}
variable "CFNCustomProviderZipFileName" {
  type = string
  default = "lambdas/network-interface-manager-0.1.5.zip"
}
variable "function_name" {
  type = string
  default = "network-interface-manager"
}