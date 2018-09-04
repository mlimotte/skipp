locals {
  service_name      = "bridge"
  qualified_service = "${var.environment}-${local.service_name}"
}

// Note: don't need this yet; for now, we're just relying on the "default" listener
//resource "aws_lb_target_group" "bridge" {
//  name        = "${local.qualified_service}"
//  target_type = "ip"
//  # This is the port on the target
//  port        = 8080
//  protocol    = "HTTP"
//  vpc_id      = "${module.ecs.vpc_id}"
//  health_check {
//    path     = "/healthcheck"
//    protocol = "HTTP"
//    matcher  = "200-299"
//  }
//}

# TODO Not needed, as there is already a "fallback" listener for
#   port 80 for traffic => default_alb_target_group
//resource "aws_lb_listener_rule" "host_rule" {
//  listener_arn = "${var.lb_listener_port443_arn}"
//  action {
//    type             = "forward"
//    target_group_arn = "${aws_lb_target_group.bridge.arn}"
//  }
//  condition {
//    field  = "host-header"
//    values = ["${local.service_name}.${var.environment}.fairhomemaine.com"]
//  }
//}


resource "aws_cloudwatch_log_group" "ecs_bridge" {
  # This log group is targeted by the TaskDef containerDefinitions
  name = "/${var.environment}/ecs/${local.service_name}"
  tags {
    Environment = "${var.environment}"
    Application = "${local.service_name}"
  }
}

resource "aws_ecs_service" "bridge" {
  name                              = "${local.service_name}"
  cluster                           = "${module.ecs.cluster_id}"
  task_definition                   = "${local.qualified_service}:1"
  desired_count                     = 1
  //  launch_type = "FARGATE"
  health_check_grace_period_seconds = 15

  iam_role                          = "${module.ecs.ecs_lb_role_arn}"

  load_balancer {
    //    target_group_arn = "${aws_lb_target_group.promos.arn}"
    target_group_arn = "${module.ecs.default_alb_target_group_arn}"
    # container_* matches the taskdek container settings
    container_name   = "${local.qualified_service}"
    container_port   = 8080
    # change to 8443 if we have node expose only HTTPS
  }

  // TODO for Fargate (due to network="awsvpc"), set network_configuration
  //  network_configuration {
  //    # assign_public_ip is required for fargate to pull image from ECR:
  //    // assign_public_ip = true
  //    subnets = [
  //      # private subnets, which can only be accessed by the LB
  //      #"${module.ecs.public_subnet_ids}"
  //      "${module.ecs.private_subnet_ids}"
  //    ]
  //    security_groups = [
  //      "${aws_security_group.ecs_container_bridge.id}"]
  //  }

  lifecycle {
    ignore_changes = [
      "desired_count",
      "task_definition"]
  }
}

//resource "aws_security_group" "ecs_container_bridge" {
//  name = "ecs-container-${local.service_name}"
//  description = "Incoming to the internal ${local.service_name}"
//  vpc_id = "${module.ecs.vpc_id}"
//
//  ingress {
//    from_port = 8080
//    to_port = 8080
//    protocol = "tcp"
//    security_groups = [
//      "${var.incoming_security_group_id}"
//    ]
//  }
//
//  ingress {
//    from_port = 8443
//    to_port = 8443
//    protocol = "tcp"
//    security_groups = [
//      "${var.incoming_security_group_id}"
//    ]
//  }
//
//  egress {
//    from_port = 0
//    to_port = 0
//    protocol = "-1"
//    cidr_blocks = [
//      "0.0.0.0/0"]
//  }
//}

### IAM

resource "aws_iam_role" "bridge" {
  name = "${var.environment}-${local.service_name}"
  force_detach_policies = true
  assume_role_policy = "${file("ecs-tasks-assume-role-policy.json")}"
}

// TODO attach additional policies as needed
//resource "aws_iam_role_policy_attachment" "s3_foo_bucket" {
//  role = "${aws_iam_role.bridge.name}"
//  policy_arn = "${var.s3_foo_bucket_r_arn}"
//}
