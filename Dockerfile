FROM hashicorp/terraform:light

RUN \
    apk add --no-cache \
        bash \
        python3 \
        py-pip \
    && pip install awscli
