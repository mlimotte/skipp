# Groups

## Group: employee

resource "aws_iam_group" "employee" {
  name = "employee"
  path = "/users/"
}

resource "aws_iam_policy" "employee" {
  name   = "employee"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "s3:List*"
        ],
        "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "employee_group_policy_attach" {
  group      = "${aws_iam_group.employee.id}"
  policy_arn = "${aws_iam_policy.employee.arn}"
}

resource "aws_iam_policy" "user_credential_mgmt" {
  name = "user-credential-mgmt"
  policy = "${file("policies/user-credential-mgmt.json")}"
}

resource "aws_iam_group_policy_attachment" "employee_group_user_creds_policy_attach" {
  group      = "${aws_iam_group.employee.id}"
  policy_arn = "${aws_iam_policy.user_credential_mgmt.arn}"
}

## Group: Engineering

resource "aws_iam_group" "engineering" {
  name = "engineering"
  path = "/users/"
}

resource "aws_iam_policy" "engineering" {
  name   = "engineering"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": "ec2:Describe*",
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": "elasticloadbalancing:Describe*",
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "cloudwatch:ListMetrics",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:Describe*"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": "autoscaling:Describe*",
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [ "s3:GetObject", "s3:PutObject", "s3:PutObjectAcl", "s3:DeleteObject",
                    "s3:GetObjectAcl", "s3:GetObjectVersionAcl", "s3:GetBucketAcl" ],
        "Resource": [
          "arn:aws:s3:::skipp-xfer/*",
          "arn:aws:s3:::skipp-data/*"
        ]
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "engineering" {
  group      = "${aws_iam_group.engineering.id}"
  policy_arn = "${aws_iam_policy.engineering.arn}"
}

## Group: Product

resource "aws_iam_group" "product" {
  name = "product"
  path = "/users/"
}

resource "aws_iam_policy" "product" {
  name   = "product"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [ "s3:GetObject", "s3:PutObject", "s3:PutObjectAcl", "s3:DeleteObject",
                    "s3:GetObjectAcl", "s3:GetObjectVersionAcl", "s3:GetBucketAcl" ],
        "Resource": [
          "arn:aws:s3:::skipp-xfer/*",
          "arn:aws:s3:::skipp-data/*"
        ]
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "product" {
  group      = "${aws_iam_group.product.id}"
  policy_arn = "${aws_iam_policy.product.arn}"
}

# Users

# NOTE 1
#   These resources create the IAM users and associated policies.
#   We do not create the "login profiles" necessary to log in to the AWS Console.
#   For that, use the AWS CLI:
#
#     aws iam create-login-profile --user-name USER_NAME --password '______' --password-reset-required
#
#   This can only be done after the iam user is created via terraform. Generate a random
#   password and use some secure method such as keybase of https://onetimesecret.com/ to
#   send it to the new user.

# Marc Limotte
resource "aws_iam_user" "marc" {
  name = "marc"
}
resource "aws_iam_user_group_membership" "marc" {
  user = "${aws_iam_user.marc.name}"
  groups = [
    "${aws_iam_group.employee.name}",
    "${aws_iam_group.engineering.name}",
  ]
}

# Adrian von der Osten <adrian@skipp.ai>
resource "aws_iam_user" "adrian" {
  name = "adrian"
}
resource "aws_iam_user_group_membership" "adrian" {
  user = "${aws_iam_user.adrian.name}"
  groups = [
    "${aws_iam_group.employee.name}",
    "${aws_iam_group.product.name}",
  ]
}

# paperspace
# For use by the paperspace machine. Primarliy for S3 access to move files back and forth.
resource "aws_iam_user" "paperspace" {
  name = "paperspace"
}
resource "aws_iam_policy" "paperspace" {
  name   = "paperspace"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [ "s3:GetObject", "s3:PutObject", "s3:DeleteObject",
                    "s3:GetObjectAcl", "s3:GetObjectVersionAcl", "s3:GetBucketAcl",
                    "s3:List*" ],
        "Resource": [
          "arn:aws:s3:::skipp-xfer/*"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [ "s3:ListBucket" ],
        "Resource": [
          "arn:aws:s3:::skipp-xfer"
        ]
    }

  ]
}
EOF
}
resource "aws_iam_user_policy_attachment" "paperspace" {
  user       = "${aws_iam_user.paperspace.id}"
  policy_arn = "${aws_iam_policy.paperspace.arn}"
}


//# Jose Garza
//resource "aws_iam_user" "jose" {
//  name = "jose"
//}
//resource "aws_iam_user_group_membership" "jose" {
//  user = "${aws_iam_user.jose.name}"
//  groups = [
//    "${aws_iam_group.employee.name}",
//    "${aws_iam_group.engineering.name}",
//  ]
//}

