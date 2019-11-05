# 
# OBSOLETE
# This terraform project is obsolete.  Use common_cdk instead.
#

# Install terraform

On a Mac, use Homebrew:

    brew install terraform

I recommend installing the "Hashicorp Terraform" (with completion, syntax highlighting, 
error detection and more) for IntelliJ

# Documentation

New user "Getting Started" guide:
https://www.terraform.io/intro/getting-started/install.html

A reference for AWS resources:
https://www.terraform.io/docs/providers/aws/

# Usage
    
## AWS creds

You need to set terraform vars for your AWS creds. There are several ways to do
this in the terraform docs.  Here is one way:

    export TF_VAR_skipp_access_key=...
    export TF_VAR_skipp_secret_key=...

## Commands

Run once (or when requested by terraform):

    terraform init

To see changes that will be applied:

    terraform plan
    
To apply changes:

    terraform apply


# Conventions

1. Try to use "_" instead of "-" for word separation in terraform resource names

2. Try to make terraform resource names match the AWS names/identifiers (but replace "_" 
   with "-"), as much as possible... limited by AWS name restrictions per resource. One 
   limitation is that many AWS resources allow only hyphen, not "_".
   
3. If your resource name includes an environment specifier, e.g. "qa1"; add that as a
   prefix (not suffix): "qa1_*"

# Free Tier -- Instance

The free tier includes 1 t2.micro EC2 instance.
We have it set up as a ECS instance, and allow direct ssh access, which is insecure, but 
keeps us within the Free Tier set up with no bastion server.

You can connect to this instance and use docker to see what's running. In particular, 
the `amazon/amazon-ecs-agent` container should be running.

Example: 

    # Note: public hostname will vary
    $ ssh -i ~/.ssh/skipp_prod_rsa ec2-user@ec2-18-208-224-193.compute-1.amazonaws.com
    >> $ docker ps
