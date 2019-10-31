FROM hashicorp/terraform:0.12.12

RUN \
    apk add --no-cache \
        bash \
        python3 \
        py-pip \
    && pip install awscli
