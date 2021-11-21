import os
from dotenv import load_dotenv
load_dotenv(dotenv_path=f"env/.{os.getenv('DOT_ENV')}.env")

import logging

logger = logging.getLogger()
logger = logging.getLogger()

def handler(event, context):
    logger.info(event)
    logger.info(context)
    logger.info("b_done")
    

    return {
        "key": "B_DONE"
    }