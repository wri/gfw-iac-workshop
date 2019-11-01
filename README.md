# gfw-iac-workshop

## Gotchas

Lambda@Edge functions are replicated to CloudFront edge nodes to localize execution. This leads to an error when Terrafrom attempts to destroy the Lambda function associated with a distribution. In the short-term, the best workaround appears to be to wait for ~1 hour after a `destroy` attempt fails, then try again.

See: https://github.com/terraform-providers/terraform-provider-aws/issues/1721
