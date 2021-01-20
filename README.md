# Let's Encrypt Wildcard SSL

Get Let's Encrypt Wildcard SSL for a Domain using AWS Route53 for ACME authentication.
After generation, the certificates will be uploaded to S3 bucket at path `s3://<s3_bucket>/letsencrypt/<domain>/`. 

# Docker Image

- Pull docker image:
  ```
  docker pull anmolsharmaa/letsencrypt-ssl
  ```
- Build your own image:
  ```
  docker build -t letsencrypt-ssl .
  ```

# Generate SSL

### Prerequisite

- A domain/subdomain with it's DNS service hosted on [AWS Route 53](https://aws.amazon.com/route53/).
- Create a [S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-bucket.html) to store SSL certificates. 
- AWS [IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html) with programmatic credentials having,
    - access to route53 resource(dns hosted zone) equivalent to JSON policy definition given in [route53-policy.json](https://github.com/anmolsharmaa/letsencrypt-ssl/blob/master/route53-policy.json) file. 
        > In JSON policy file, replace `<hosted-zone-ID>` with the ZONE ID of your domain hosted on AWS Route53 
    - access to s3 resource(bucket) equivalent to JSON policy definition given in [s3-policy.json](https://github.com/anmolsharmaa/letsencrypt-ssl/blob/master/s3-policy.json) file. 
        > In JSON policy file, replace `<s3-bucket-name>` with the S3 BUCKET NAME that you have created in step above

### Get SSL

```
TEMP_DIR=$(mktemp -d)
mkdir -p ${TEMP_DIR}

docker run -i \
    -v ${TEMP_DIR}:/home/letsencrypt \
    anmolsharmaa/letsencrypt-ssl \
        -a aws_access_key_id \
        -b s3_bucket \
        -d domain \
        -e email \
        -s aws_secret_access_key
```