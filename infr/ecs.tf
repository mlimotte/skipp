

# TODO  maybe add an EIP instead of API Gateway
#   Or maybe we don't need either, since we have an app load balancer???

module "ecs" {
  source               = "git@github.com:arminc/terraform-ecs.git//modules/ecs"
  environment          = "${var.environment}"
  cluster              = "${var.environment}"
  #See ecs_instances module when to set cloudwatch_prefix and when not!
  cloudwatch_prefix    = "${var.environment}"
  vpc_cidr             = "${var.vpc_cidr}"
  public_subnet_cidrs  = "${var.public_subnet_cidrs}"
  private_subnet_cidrs = "${var.private_subnet_cidrs}"
  availability_zones   = "${var.availability_zones}"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"
  key_name             = "${aws_key_pair.prod_ecs.key_name}"
  instance_type        = "${var.instance_type}"
  ecs_aws_ami          = "${var.ecs_aws_ami}"
}

resource "aws_key_pair" "prod_ecs" {
  key_name   = "${var.environment}-ecs"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFWMRMgAHwovQ5AWNTuHO+CrLsdK8C2ahnn8yfM+SkQQB9f0oepY9a8vnQRiKAZDt0yEWoSnPBi/BMzS9N+CKnaM4CH8VTSTL8vppo0yr1PpA+ICh/4yT/G7DHh6cPvvVX7Mo6JNdwTQEzyn+Tt6tjGSeF3k8N0yjwwa7d5DQSpxU/ZMU54z0gHj5I9HkTjz3slnklFAB54IVjPwAjQJhFkhgpDzNcNDJGavWNC5BTCIWlESkU5/zO+1cVX7VPBjYZoVgB5V9ay3wAL61FOMH8EOs8H50DTApIUvBnshv0XrchV7hL8fYrA9pPwcqUCeRiF03t1i6ZMsPdx+tZw9+75oTntoLbvaSIMz/wqLZTG1FIDG05fufs3eXCKKHXFmQauyk9r6fq0LobaYSxB6kORvXoiYwPHH5XugaFL6WX/q32deda7qSkyZxMWdbh0/JZJCplQ2KerjsTct2S342YJ4XlxjOjyEAmK3Gsy4kj/cAo96BqRVLCU6h4T0jJYPXdpVUVUSoBdiNPAvia5zzh7ITz0jWuTyp4Ek1bvGl0ZtH3/iYs3m+Xgfm9Qqs4v91HiOR9djkPduCzKA4yHStmqRAYrbpY3FVstlUOGfMEd2mRA4ufUeY2SwsSliizTPXuHdOtDrQGLufPW0FEtp5nPGASsoTRdY5qNgxtkHJAHQ== mslimotte@gmail.com"
}

variable "vpc_cidr" {}
variable "environment" {}
variable "max_size" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "instance_type" {}
variable "ecs_aws_ami" {}

variable "private_subnet_cidrs" {
  type = "list"
}

variable "public_subnet_cidrs" {
  type = "list"
}

variable "availability_zones" {
  type = "list"
}

output "default_alb_target_group" {
  value = "${module.ecs.default_alb_target_group}"
}
