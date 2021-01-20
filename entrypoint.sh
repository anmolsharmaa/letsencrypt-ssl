#!/bin/bash

set -x -u -e

# Process CLI args
while getopts "a:b:d:e:s:" arg
do
    case "${arg}" in
        a) # aws_access_key_id
            AWS_ACCESS_KEY_ID="${OPTARG}"
            export AWS_ACCESS_KEY_ID
        ;;
        b) # s3 bucket
            S3_BUCKET="${OPTARG}"
            export S3_BUCKET
        ;;
        d) # domain
            DOMAIN="${OPTARG}"
            export DOMAIN
        ;;
        e) # email
            EMAIL="${OPTARG}"
            export EMAIL
        ;;
        s) # aws_secret_access_key
            AWS_SECRET_ACCESS_KEY="${OPTARG}"
            export AWS_SECRET_ACCESS_KEY
        ;;
        *)
            echo "error: unsupported arg"
            echo "$0 -a <aws_access_key_id> -b <s3_bucket> -d <domain> -e <email> -s <aws_secret_access_key>"
            exit 1
        ;;
    esac
done

# Generate wildcard SSL
certbot certonly \
    -d "*.${DOMAIN}" \
    -d "${DOMAIN}" \
    --dns-route53 \
    --logs-dir "${PWD}/log/" \
    --config-dir "${PWD}/config/" \
    --work-dir "${PWD}/work/" \
    -m "${EMAIL}" \
    --agree-tos \
    --non-interactive \
    --server https://acme-v02.api.letsencrypt.org/directory

# Log current timestamp
date +%s | tee "${PWD}/ts"

# Copy SSL to S3
aws s3 cp "${PWD}/config/live/${DOMAIN}/fullchain.pem" "s3://${S3_BUCKET}/letsencrypt/${DOMAIN}/"
aws s3 cp "${PWD}/config/live/${DOMAIN}/privkey.pem" "s3://${S3_BUCKET}/letsencrypt/${DOMAIN}/"
# Update timestamp in S3
aws s3 cp "${PWD}/ts" "s3://${S3_BUCKET}/letsencrypt/${DOMAIN}/"
