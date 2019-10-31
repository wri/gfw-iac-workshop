import os
import json
import boto3
from botocore.exceptions import ClientError

s3 = boto3.resource("s3")
obj = s3.Object(os.getenv("S3_BUCKET"), "messages.json")


def put_data(data):
    data = json.dumps(data)
    data = data.encode("utf-8")
    obj.put(Body=data)


def get_data():
    try:
        data = obj.get()["Body"].read()
        data = data.decode("utf-8")
        return json.loads(data)
    except ClientError:
        put_data({"messages": []})
        return get_data()


def handler(event, context):
    # Get our "todo list" from S3. If the HTTP method is POST, add a new item to
    # the list.
    if event["httpMethod"] == "POST":
        body = json.loads(event["body"])

        data = get_data()
        data["messages"].append(body["message"])
        put_data(data)

    return {
        "statusCode": 200,
        "headers": {},
        "body": json.dumps(get_data()),
        "isBase64Encoded": False,
    }
