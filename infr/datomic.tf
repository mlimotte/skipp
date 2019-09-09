//# NOTE: Most of the resources are controlled by a Cognitect Cloudformation template
//
//data "aws_instance" "datomic1_bastion" {
//  filter {
//    name = "tag:Name"
//    values = [
//      "datomic1-bastion"]
//  }
//}
//
//#datomic1-Compute-YOBYQW4NDO7V-BastionSecurityGroup-1O60LXEUBJM5T
//resource "aws_security_group" "datomic1_bastion" {
//  #sg-0e8a2d1bf9b21e479
//  name = "datomic1-Compute-YOBYQW4NDO7V-BastionSecurityGroup-1O60LXEUBJM5T"
//  description = "Security group for datomic1 bastion"
//  revoke_rules_on_delete = false
//
//  tags = {
//    "Name" = "datomic1-bastion"
//    "datomic:system" = "datomic1"
//  }
//
//  ingress {
//    from_port = 22
//    to_port = 22
//    protocol = "tcp"
//    cidr_blocks = [
//      "0.0.0.0/0"]
//  }
//
//  egress {
//    from_port = 0
//    to_port = 0
//    protocol = "-1"
//    cidr_blocks = [
//      "0.0.0.0/0"]
//  }
//
//}
//
//resource "aws_security_group_rule" "datomic1_bastion" {
//  type = "egress"
//  from_port = 0
//  to_port = 0
//  protocol = "-1"
//  cidr_blocks = [
//    "0.0.0.0/0",
//  ]
//  //      - id                = "sgrule-1601096701" -> null
//  security_group_id = aws_security_group.datomic1_bastion.id
//}
