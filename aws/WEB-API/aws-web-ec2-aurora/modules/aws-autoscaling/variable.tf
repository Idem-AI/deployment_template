variable "ami_name" {}
variable "launch-template-name" {}
variable "web-sg-name" {}
variable "tg-name" {}
variable "iam-role" {}
variable "public-subnet-name1" {}
variable "public-subnet-name2" {}
variable "instance-profile-name" {}
variable "asg-name" {}
variable "instance_type" {
  default = "t2.micro"
}


variable "private-subnet-ids" {
  type = list(string)
  
}
variable "public-subnet-ids" {
  type = list(string)
  
}
variable "web-tg-arn" {
  type = string
}
variable "app-tg-arn" {
  type = string
}

variable "aws_security_group-App-SG" {
  type = string 
  
}
variable "aws_security_group-Web-SG" {
  type = string 
  
}