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

