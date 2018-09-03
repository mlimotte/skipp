vpc_cidr = "10.0.0.0/16"

environment = "prod"

public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24"]

private_subnet_cidrs = ["10.0.50.0/24", "10.0.51.0/24"]

availability_zones = ["us-east-1b", "us-east-1e"]

max_size = 1

min_size = 1

desired_capacity = 1

instance_type = "t2.micro"

# Amazon Linux AMI 2018.03.0 (HVM), SSD Volume Type - ami-0ff8a91507f77f867
# The Amazon Linux AMI is an EBS-backed, AWS-supported image. The default image includes
#   AWS command line tools, Python, Ruby, Perl, and Java. The repositories include Docker, PHP,
#   MySQL, PostgreSQL, and other packages.
# Root device type: ebs, Virtualization type: hvm, ENA Enabled: Yes
ecs_aws_ami = "ami-0ff8a91507f77f867"
