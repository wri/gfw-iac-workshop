# gfw-iac-workshop

This repository contains the materials needed for exercises associated with a Terraform/Infrastructure as Code workshop for the World Resources Institute (WRI).

- [Overview](#overview)
- [Getting started](#getting-started)
  - [Dependencies](#dependencies)
  - [Instructions](#instructions)
- [Gotchas](#gotchas)

## Overview

The `terraform` directory contains a Terraform project, along with four Terraform modules:

- API Gateway, Fargate, and RDS (`api-gateway-fargate`)
- API Gateway, Lambda, and S3 (`api-gateway-lambda-s3`)
- CloudFront, S3, and Lambda@Edge (`cloudfront-s3-lambda-at-edge`)
- Virtual Private Cloud (`vpc`)

The `src` directory contains a small Flask application for use with the `api-gateway-fargate` Terraform module.

The `scripts` directory contains three scripts:

- `cibuild` is responsible for building a Flask container image for the application in `src`.
- `cipublish` is responsible for publishing that container image to Amazon ECR.
- `infra` is a wrapper for the `terraform` command that also manages initialization.

## Getting started

### Dependencies

- AWS CLI 1.16+
- Docker 19.03+
- Docker Compose 1.24+

### Instructions

First, copy the following file, renaming it to `gfw-iac-workshop.tfvars` in the process:

```
cp terraform/gfw-iac-workshop.tfvars.example terraform/gfw-iac-workshop.tfvars
```

Then, customize its contents with a text editor:

- For `project`, use your name in title case.
- For `bucket_name`, use a unique name that is unlikely to collide with other bucket names in S3.
- For `aws_key_name`, follow [these](https://docs.aws.amazon.com/en_pv/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair) instructions to generate a custom EC2 key pair for yourself. Assign the key pair name you select as the value for `aws_key_name`.
- For `ecr_repository_uri`, create a repository with the AWS CLI and use the value for `repositoryUri` from the output:

```
export AWS_PROFILE=wri
aws ecr create-repository --repository-name hello-repository
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:us-east-1:942210422222:repository/hello-repository",
        "registryId": "942210422222",
        "repositoryName": "hello-repository",
        "repositoryUri": "942210422222.dkr.ecr.us-east-1.amazonaws.com/hello-repository",
        "createdAt": 1572919870.0,
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        }
    }
}
```

Here's an example of a customized `gfw-iac-workshop.tfvars`:

```
project = "Peppa"
environment = "Staging"
bucket_name = "PeppaPig"
aws_key_name = "wri-iac-workshop"
ecr_repository_uri = "942210422222.dkr.ecr.region.amazonaws.com/hello-repository"
```

Next, build a container image for the Flask application (`cibuild`), then publish it to Amazon ECR (`cipublish`):

```
export GFW_IAC_WORKSHOP_AWS_ECR_ENDPOINT="942210422222.dkr.ecr.us-east-1.amazonaws.com/hello-repository"
./scripts/cibuild
./scripts/cipublish
```

Lastly, launch an instance of the included Terraform container image:

```
docker-compose build
docker-compose run --rm terraform
bash-5.0#
```

Once inside the context of the container image, use `infra` to generate a Terraform plan:

```
bash-5.0# ./scripts/infra plan
```

## Gotchas

Lambda@Edge functions are replicated to CloudFront edge nodes to localize execution. This leads to an error when Terrafrom attempts to destroy the Lambda function associated with a distribution. In the short-term, the best workaround appears to be to wait for ~1 hour after a `destroy` attempt fails, then try again.

See: https://github.com/terraform-providers/terraform-provider-aws/issues/1721
