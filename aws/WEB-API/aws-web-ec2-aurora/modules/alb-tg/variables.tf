variable "public-subnet-name1" {}
variable "public-subnet-name2" {}
variable "web-alb-sg-name" {}
variable "tg-name" {}
variable "vpc-name" {}
variable "web-alb-name" {}
variable "vpc_id" {}
variable "web-elb-sg" {
  type = string
}
variable "public-subnet-ids" {
  type = list(string)   
}
variable "private-subnet-ids" {
  type = list(string)   
}
variable "app-elb-sg-id" {
  type = string
}
variable "web-sg-id" {
  type = string
}
variable "app-sg-id" {
  type = string
}

variable "app-alb-name" {}