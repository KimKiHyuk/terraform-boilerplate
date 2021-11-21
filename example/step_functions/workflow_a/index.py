import os
from dotenv import load_dotenv
load_dotenv(dotenv_path=f"env/.{os.getenv('DOT_ENV')}.env")

import logging

logger = logging.getLogger()

def handler(event, context):
    logger.info(event)
    logger.info(context)
    logger.error("error1")
    logger.critical('critical')
    

    return {
        "key": event["key"]
    }