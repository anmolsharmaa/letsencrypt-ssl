FROM python:3.8-slim

RUN pip install --upgrade pip \
    && pip install awscli \
        boto3 \
        certbot_dns_route53

COPY ./entrypoint.sh /

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

WORKDIR /home/letsencrypt