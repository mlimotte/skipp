output "default_alb_target_group_arn" {
  value = "${module.alb.default_alb_target_group}"
}

output "vpc_id" {
  value = "${module.network.vpc_id}"
}

output "cluster_id" {
  value = "${aws_ecs_cluster.cluster.id}"
}

output "public_subnet_ids" {
  value = "${module.network.public_subnet_ids}"
}

output "private_subnet_ids" {
  value = "${module.network.private_subnet_ids}"
}

output "ecs_lb_role_arn" {
  value = "${aws_iam_role.ecs_lb_role.arn}"
}

output "ecs_instance_security_group_id" {
  value = "${module.ecs_instances.ecs_instance_security_group_id}"
}
