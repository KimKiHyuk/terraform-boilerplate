import os
import json
from dotenv import load_dotenv
load_dotenv(dotenv_path="env/.env")

import logging
import boto3

client = boto3.client('stepfunctions')

my_state_machine_arn = os.getenv('MY_STATE_MACHINE_ARN')

logger = logging.getLogger()

def handler(event, context):
    logger.info(event)
    response = client.start_execution(
        stateMachineArn=my_state_machine_arn,
        input=json.dumps({"key": event["key"]})
    )
    logger.info(response)

    