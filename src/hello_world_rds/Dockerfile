FROM python:3.8-alpine

RUN mkdir -p /usr/local/src
WORKDIR /usr/local/src

COPY requirements.txt /tmp/

RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
        postgresql-dev \
        gcc \
        python3-dev \
        musl-dev \
    && apk add --no-cache \
        libpq \
    && pip install --no-cache-dir -r /tmp/requirements.txt \
    && apk del .build-deps \
    && rm -rf /tmp/requirements.txt

COPY . /usr/local/src

ENV FLASK_APP=app.py

ENTRYPOINT ["/usr/local/bin/flask"]

CMD ["run", "--host=0.0.0.0"]
