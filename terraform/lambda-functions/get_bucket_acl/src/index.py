import os
import json
import boto3

s3 = boto3.client("s3")


def handler(event, context):
    return {
        "statusCode": 200,
        "headers": {},
        "body": json.dumps(s3.get_bucket_acl(Bucket=os.environ["S3_BUCKET"])),
        "isBase64Encoded": False,
    }
