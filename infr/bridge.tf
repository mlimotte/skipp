//locals {
//  service_name      = "bridge"
//  qualified_service = "${var.environment}-${local.service_name}"
//}
//
//resource "aws_cloudwatch_log_group" "ecs_bridge" {
//  # This log group is targeted by the TaskDef containerDefinitions
//  name = "/${var.environment}/ecs/${local.service_name}"
//  tags = {
//    Environment = "${var.environment}"
//    Application = "${local.service_name}"
//  }
//}
//
//resource "aws_ecs_service" "bridge" {
//  name                              = "${local.service_name}"
//  cluster                           = "${aws_ecs_cluster.prod.id}"
//  task_definition                   = "${local.qualified_service}:1"
//  launch_type                       = "EC2"
//  desired_count                     = 1
//  health_check_grace_period_seconds = 15
//  iam_role                          = "${aws_iam_role.cluster_service.name}"
//
//  load_balancer {
//    target_group_arn = "${aws_alb_target_group.default.arn}"
//    container_name   = "${local.qualified_service}"
//    container_port   = 8080
//  }
//
//  lifecycle {
//    ignore_changes = [
//      "desired_count",
//      "task_definition"]
//  }
//}
//
//
//### IAM
//
//resource "aws_iam_role" "bridge" {
//  name                  = "${var.environment}-${local.service_name}"
//  force_detach_policies = true
//  assume_role_policy    = "${file("ecs-tasks-assume-role-policy.json")}"
//}
//
//resource "aws_iam_policy" "bridge" {
//  name   = "bridge"
//  policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//        "Effect": "Allow",
//        "Action": [ "s3:GetObject", "s3:PutObject", "s3:PutObjectAcl", "s3:DeleteObject",
//                    "s3:GetObjectAcl", "s3:GetObjectVersionAcl", "s3:GetBucketAcl" ],
//        "Resource": [
//          "arn:aws:s3:::skipp-data/*"
//        ]
//    }
//  ]
//}
//EOF
//}
//
//resource "aws_iam_role_policy_attachment" "s3_skipp-data" {
//  role = "${aws_iam_role.bridge.name}"
//  policy_arn = "${aws_iam_policy.bridge.arn}"
//}
//
