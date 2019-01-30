//module "ecs" {
//  //source               = "git@github.com:arminc/terraform-ecs.git//modules/ecs"
//  source               = "terraform-ecs-modules/ecs"
//  environment          = "${var.environment}"
//  cluster              = "${var.environment}"
//  #See ecs_instances module when to set cloudwatch_prefix and when not!
//  cloudwatch_prefix    = "${var.environment}"
//  vpc_cidr             = "${var.vpc_cidr}"
//  public_subnet_cidrs  = "${var.public_subnet_cidrs}"
//  private_subnet_cidrs = "${var.private_subnet_cidrs}"
//  availability_zones   = "${var.availability_zones}"
//  max_size             = "${var.max_size}"
//  min_size             = "${var.min_size}"
//  desired_capacity     = "${var.desired_capacity}"
//  key_name             = "${aws_key_pair.prod_ecs.key_name}"
//  instance_type        = "${var.instance_type}"
//  ecs_aws_ami          = "${var.ecs_aws_ami}"
//}

## Repo

resource "aws_ecr_repository" "bridge" {
  name = "bridge"
}

## Cluster

resource "aws_ecs_cluster" "prod" {
  name = "prod"
}

data "aws_ami" "amazon_linux_ecs" {
  # The AWS ECS optimized ami <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html>
  most_recent = true
  filter {
    name   = "name"
    values = [
      "amzn2-ami-ecs-hvm-2.0.20181112-x86_64-ebs"]
  }
  filter {
    name   = "owner-alias"
    values = [
      "amazon"]
  }
}

resource "aws_key_pair" "prod_ecs" {
  key_name   = "${var.environment}-ecs"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFWMRMgAHwovQ5AWNTuHO+CrLsdK8C2ahnn8yfM+SkQQB9f0oepY9a8vnQRiKAZDt0yEWoSnPBi/BMzS9N+CKnaM4CH8VTSTL8vppo0yr1PpA+ICh/4yT/G7DHh6cPvvVX7Mo6JNdwTQEzyn+Tt6tjGSeF3k8N0yjwwa7d5DQSpxU/ZMU54z0gHj5I9HkTjz3slnklFAB54IVjPwAjQJhFkhgpDzNcNDJGavWNC5BTCIWlESkU5/zO+1cVX7VPBjYZoVgB5V9ay3wAL61FOMH8EOs8H50DTApIUvBnshv0XrchV7hL8fYrA9pPwcqUCeRiF03t1i6ZMsPdx+tZw9+75oTntoLbvaSIMz/wqLZTG1FIDG05fufs3eXCKKHXFmQauyk9r6fq0LobaYSxB6kORvXoiYwPHH5XugaFL6WX/q32deda7qSkyZxMWdbh0/JZJCplQ2KerjsTct2S342YJ4XlxjOjyEAmK3Gsy4kj/cAo96BqRVLCU6h4T0jJYPXdpVUVUSoBdiNPAvia5zzh7ITz0jWuTyp4Ek1bvGl0ZtH3/iYs3m+Xgfm9Qqs4v91HiOR9djkPduCzKA4yHStmqRAYrbpY3FVstlUOGfMEd2mRA4ufUeY2SwsSliizTPXuHdOtDrQGLufPW0FEtp5nPGASsoTRdY5qNgxtkHJAHQ== mslimotte@gmail.com"
}


//////////

resource "aws_iam_role" "cluster_instance" {
  name               = "awsDockerClusterInstanceRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster_instance_ssm" {
  role       = "${aws_iam_role.cluster_instance.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "cluster_instance_ecs" {
  role       = "${aws_iam_role.cluster_instance.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "docker" {
  name = "awsDockerClusterInstanceProfile"
  role = "${aws_iam_role.cluster_instance.name}"
}

resource "aws_iam_role" "cluster_service" {
  name               = "awsDockerClusterServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster_service" {
  role       = "${aws_iam_role.cluster_service.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

# security groups (free) instead of vpc (NAT $30/mo)

resource "aws_default_vpc" "default" {
  tags {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_1a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_1c" {
  availability_zone = "us-east-1c"
}

resource "aws_default_subnet" "default_1d" {
  availability_zone = "us-east-1d"
}

resource "aws_security_group" "docker_alb" {
  name        = "docker-alb"
  description = "security group for aws docker load balancer"
  vpc_id      = "${aws_default_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_security_group" "docker_instances" {
  name        = "aws-docker-instances-sg"
  description = "security group for aws docker cluster instances"
  vpc_id      = "${aws_default_vpc.default.id}"

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [
      "${aws_security_group.docker_alb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

# launch stuff
resource "aws_launch_configuration" "docker" {
  name                 = "aws-docker-cluster-launch-config"
  image_id             = "${data.aws_ami.amazon_linux_ecs.id}"
  instance_type        = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.docker.name}"
  user_data            = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.prod.name} >> /etc/ecs/ecs.config
    EOF
  security_groups      = [
    "${aws_security_group.docker_instances.id}"]
  key_name             = "${aws_key_pair.prod_ecs.key_name}"
}

# autoscaling
resource "aws_autoscaling_group" "docker_asg" {
  name                 = "aws-docker-cluster-scaling-group"
  availability_zones   = [
    "us-east-1a",
    "us-east-1c",
    "us-east-1d"]
  launch_configuration = "${aws_launch_configuration.docker.name}"
  min_size             = 0
  max_size             = 2
  desired_capacity     = 1

  tag {
    key                 = "Name"
    value               = "AWS Docker Cluster Instance"
    propagate_at_launch = true
  }
}

# application load balancer
resource "aws_alb" "alb" {
  name            = "aws-docker-cluster-alb"
  internal        = false
  security_groups = [
    "${aws_security_group.docker_alb.id}"]
  subnets         = [
    "${aws_default_subnet.default_1a.id}",
    "${aws_default_subnet.default_1c.id}",
    "${aws_default_subnet.default_1d.id}"]
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.default.id}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "default" {
  name     = "aws-docker-cluster-targets"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_default_vpc.default.id}"

  health_check {
    path     = "/healthcheck"
    protocol = "HTTP"
  }
}
