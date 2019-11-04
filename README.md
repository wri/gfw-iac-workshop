# gfw-iac-workshop

This repository contains the materials needed for exercises associated with a Terraform/Infrastructure as Code workshop for the World Resources Institute (WRI).

## Table of contents

- [Table of contents](#table-of-contents)
- [Overview](#overview)
- [Getting started](#getting-started)
- [Gotchas](#gotchas)

## Overview

The `terraform` directory contains a Terraform project, along with four Terraform modules:

- API Gateway, Fargate, and RDS (`api-gateway-fargate`)
- API Gateway, Lambda, and S3 (`api-gateway-lambda-s3`)
- CloudFront, S3, and Lambda@Edge (`cloudfront-s3-lambda-at-edge`)
- Virtual Private Cloud (`vpc`)

The `src` directory contains a small Flask application for use with the `api-gateway-fargate` Terraform module.

The `scripts` directory contains three scripts:

- `cibuild` is responsible for building a Flask container image for the application in `src`
- `cipublish` is responsible for publishing that container image to Amazon ECR
- `infra` is a helper wrapper for the `terraform` command

## Getting started

First, copy the following file, renaming it to `gfw-iac-workshop.tfvars` in the process:

```console
cp terraform/gfw-iac-workshop.tfvars.example terraform/gfw-iac-workshop.tfvars
```

Then, customize its contents with a text editor:

- For `project`, use your name in TitleCase.
- For `bucket_name`, use a unique name that is unlikely to collide with other bucket names in S3.
- For `aws_key_name`, follow [these](https://docs.aws.amazon.com/en_pv/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair) instructions to generate a custom EC2 key pair for yourself. Assign the key pair name you select as the value for `aws_key_name`.

Here's an example:

```
project = "Peppa"
environment = "Staging"
bucket_name = "PeppaPig"
aws_key_name = "wri-iac-workshop"
```

Second, launch an instance of the included Terraform container image:

```console
docker-compose build
docker-compose run --rm terraform
bash-5.0#
```

Next, build a container image for the Flask application and publish it to Amazon ECR using the following two commands:

```console
./scripts/cibuild
./scripts/cipublish
```

## Gotchas

Lambda@Edge functions are replicated to CloudFront edge nodes to localize execution. This leads to an error when Terrafrom attempts to destroy the Lambda function associated with a distribution. In the short-term, the best workaround appears to be to wait for ~1 hour after a `destroy` attempt fails, then try again.

See: https://github.com/terraform-providers/terraform-provider-aws/issues/1721
