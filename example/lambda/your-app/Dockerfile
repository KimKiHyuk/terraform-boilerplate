FROM public.ecr.aws/lambda/python:3.8

COPY requirements.txt requirements.txt
COPY env/ env/
COPY index.py ${LAMBDA_TASK_ROOT}

RUN pip install -r requirements.txt

ARG DOT_ENV
ENV DOT_ENV ${DOT_ENV}

CMD [ "index.handler" ]