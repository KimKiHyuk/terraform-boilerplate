FROM public.ecr.aws/lambda/python:3.8

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY env/ env/

COPY index.py ${LAMBDA_TASK_ROOT}

ENV VERSION "1.0"
ARG BUILD_DATE

ENV BUILD_DATE ${BUILD_DATE}


CMD [ "index.handler" ]