FROM python:3.9.12-slim-buster AS build

ARG CONNECTOR_VERSION=latest
ENV CONNECTOR_VERSION=${CONNECTOR_VERSION}

COPY requirements.txt /app/requirements.txt
RUN python3 -m pip install -r app/requirements.txt

COPY . /app

CMD ["/app/bin/run-model", "/data/input/inputFile.json", "/data/output/data.json", "/app/input-schema.json", "/app/output-schema.json"]
