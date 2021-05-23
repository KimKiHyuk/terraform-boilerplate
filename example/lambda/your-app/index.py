import boto3
import os
from dotenv import load_dotenv
from PIL import Image
from io import BytesIO
from enum import Enum
import urllib.parse
import zipfile

s3 = boto3.resource("s3")


def handler(event, context):
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = urllib.parse.unquote_plus(
        event["Records"][0]["s3"]["object"]["key"], encoding="utf-8"
    )

    print("env : ", os.getenv("DOT_ENV"))
    load_dotenv(dotenv_path=f"env/.{os.getenv('DOT_ENV', 'development')}.env")

    zip_obj = s3.Object(bucket_name=bucket, key=key)
    buffer = BytesIO(zip_obj.get()["Body"].read())

    z = zipfile.ZipFile(buffer)

    for filename in z:
        s3.meta.client.upload_fileobj(
            z.open(filename),
            Bucket=bucket,
            Key=os.path.join("<your-s3-location>", filename),
        )
