import os
from dotenv import load_dotenv
load_dotenv(dotenv_path=f"env/.{os.getenv('DOT_ENV')}.env")

import logging

logger = logging.getLogger()

def handler(event, context):
    logger.info(event)
    logger.info(context)
    
    logger.info("C_done")

    return {
        "key": "C_DONE"
    }
