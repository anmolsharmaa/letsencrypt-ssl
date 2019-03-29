**[main.sh](https://github.com/anmolsharmaa/letsencrypt-ssl/blob/master/main.sh)** is the shell script used for issuing and renewing a Let's Encrypt Wildcard SSL.  This shell script mainly uses [certbot](https://certbot.eff.org/about/) and [awscli](https://aws.amazon.com/cli/) to get this process done. And, at last, this script uploads the SSL certificates to a AWS S3 bucket.


Supported Linux OS
-----
    - Debian (>= 7)
    - Ubuntu (>= 14.04)


Prerequisite
-----

To issue/renew letsencrypt wildcard SSL, you need:

- A domain/subdomain having it's DNS service hosted on [AWS Route 53](https://aws.amazon.com/route53/)
- create a [S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-bucket.html), where you want to store SSL certficates 
- AWS [IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html) with programmatic credentials having,

     - access to route53 resource(dns hosted zone) equivalent to JSON policy defination given in [route53-policy.json](https://github.com/anmolsharmaa/letsencrypt-ssl/blob/master/route53-policy.json) file. **Note:** _In JSON policy file, replace `<hosted-zone-ID>` with the ZONE ID of your domain hosted on AWS Route53_ 
     - access to s3 resource(bucket) equivalent to JSON policy defination given in [s3-policy.json](https://github.com/anmolsharmaa/letsencrypt-ssl/blob/master/s3-policy.json) file. **Note:** _In JSON policy file, replace `<s3-bucket-name>` with the S3 BUCKET NAME that you have created in step above_
- `[optional]` have **Docker** (version >= 18.09) and **docker-compose** (version >= 1.23) installed. To install/upgrade docker and docker-compose, use commands below on Linux system:

    ```
    sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /bin/docker-compose
    sudo chmod +x /bin/docker-compose
    sudo curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    ```


Steps to issue a Let's Encrypt SSL
-----

- Git clone this repository.
- Install `python`, `openssl` and `wget`. **OR** Run below command to get it done:
    - **Note:** _Requires sudo access to Linux User_
    ```
    sudo bash main.sh init
    ```
- Run below command to get SSL certificate:
     ```
     bash main.sh issue --domain <domain-name> --s3-bucket <s3-bucket-name> --email <email-id> --aws-access-key <aws-access-key-id> --aws-secret-key <aws-secret-access-key>
     ```
     - in command above:
        - replace placeholders enclosed within <> with appropriate values.
        - <email-id> is the email ID where, you want to receive email alerts regarding Let's Encrypt SSL certificate status.


Steps to renew a Let's Encrypt SSL
-----

The renew operation will only renew the certificates when days left in certificate expriation is less then 30 days.

- Git clone this repository.
- Install `python` and `wget`. **OR** Run below command to get it done:
    - **Note:** _Requires sudo access to Linux User_
    ```
    sudo bash main.sh init
    ```
- Run below command to get SSL certificate:
    ```
    bash main.sh renew --domain <domain-name> --s3-bucket <s3-bucket-name> --email <email-id> --aws-access-key <aws-access-key-id> --aws-secret-key <aws-secret-access-key>
    ```
    - in command above:
        - replace placeholders enclosed within <> with appropriate values.
        - `<email-id>` is the email ID where, you want to receive email alerts regarding Let's Encrypt SSL certificate status.


Preferably, you may want to set a cronjob to automatically renew Let's Encrypt SSL
-----

```
@weekly bash main.sh renew --domain <domain-name> --s3-bucket <s3-bucket-name> --email <email-id> --aws-access-key <aws-access-key-id> --aws-secret-key <aws-secret-access-key>
```
- instead of using `@weekly`, feel free to use any cron scheduling pattern as per your convenience.
- **Note: irrespective of cron schedule, the `renew` action performs only when days left in certificate expiration is less than 30 days.**
