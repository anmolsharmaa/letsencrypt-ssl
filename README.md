# Let's Encrypt Wildcard SSL

Get Let's Encrypt Wildcard SSL for a Domain using AWS Route53 for ACME authentication.
After generation, the certificates will be uploaded to S3 bucket at path `s3://<s3_bucket>/letsencrypt/<domain>`. 

# Build Docker Image

```
docker build -t anmolsharmaa/letsencrypt-ssl .
```

# Generate Wildcard SSL

```
docker run -i -v ${PWD}:/home/letsencrypt anmolsharmaa/letsencrypt-ssl \
    -a aws_access_key_id \
    -b s3_bucket \
    -d domain \
    -e email \
    -s aws_secret_access_key
```