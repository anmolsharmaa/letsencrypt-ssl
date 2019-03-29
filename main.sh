#!/bin/bash

function install_requirements () {
	wget -q -O /tmp/lets-install-pip.py  https://bootstrap.pypa.io/get-pip.py
	python https://bootstrap.pypa.io/get-pip.py --user
	export PATH=$HOME/bin:$HOME/.local/bin:$PATH
	pip install awscli boto3 certbot_dns_route53 --user
}


function check_requirements () {
	export PATH=$HOME/bin:$HOME/.local/bin:$PATH
	if [[ ! -f $(type -P python) ]]; then
		echo -e "- - - - -\npython not found.\nRun this script with --init flag.\n"
	fi
	if [[ ! -f $(type -P pip) ]]; then install_requirements; fi
	if [[ ! -f $(type -P aws) ]]; then install_requirements; fi
	if [[ ! -f $(type -P certbot) ]]; then install_requirements; fi
}


function set_args_to_env () {
	while test $# -gt 0;
	do
		case $1 in
			--s3-bucket)
				shift
				export S3_BUCKET=$1
				shift
			;;
			--domain)
				shift
				export DOMAIN=$1
				shift
			;;
			--email)
				shift
				export EMAIL=$1
				shift
			;;
			--aws-access-key)
				shift
				export AWS_ACCESS_KEY_ID=$1
				shift	
			;;
			--aws-secret-key)
				shift
				export AWS_SECRET_ACCESS_KEY=$1
				shift
			;;
		esac
	done
}


function issue_ssl () {
	set_args_to_env $@
	export PATH=$HOME/bin:$HOME/.local/bin:$PATH
	aws s3api put-object --bucket ${S3_BUCKET} --key letsencrypt/${DOMAIN} >/dev/null
	certbot certonly -d *.${DOMAIN} -d ${DOMAIN} --dns-route53 --logs-dir ~/letsencrypt/log/ --config-dir ~/letsencrypt/config/ --work-dir ~/letsencrypt/work/ -m ${EMAIL} --agree-tos --non-interactive --server https://acme-v02.api.letsencrypt.org/directory >/dev/null
	aws s3 cp ~/letsencrypt/config/live/${DOMAIN}/fullchain.pem s3://st-ssl/letsencrypt/${DOMAIN}/ >/dev/null
	aws s3 cp ~/letsencrypt/config/live/${DOMAIN}/privkey.pem s3://st-ssl/letsencrypt/${DOMAIN}/ >/dev/null
	sleep 15s
	certbot --logs-dir ~/letsencrypt/log/ --config-dir ~/letsencrypt/config/ --work-dir ~/letsencrypt/work/ delete --cert-name ${DOMAIN} >/dev/null
} 


function renew_ssl () {
	set_args_to_env $@
	export PATH=$HOME/bin:$HOME/.local/bin:$PATH
	mkdir -p /data/certs
    	aws s3 cp --recursive s3://${BUCKET}/ /data/certs/
	days_left=$(( ($(date -d "$(openssl x509 -in /data/certs/letsencrypt/${DOMAIN}/fullchain.pem -noout -dates | grep notAfter | cut -d= -f2)" +%s) - $(date +%s)) / (60*60*24) ))
	if [[ $days_left -lt 30 ]]; then
		certbot certonly -d *.${DOMAIN} -d ${DOMAIN} --dns-route53 --logs-dir ~/letsencrypt/log/ --config-dir ~/letsencrypt/config/ --work-dir ~/letsencrypt/work/ -m ${EMAIL} --agree-tos --non-interactive --server https://acme-v02.api.letsencrypt.org/directory >/dev/null
        	aws s3 cp ~/letsencrypt/config/live/${DOMAIN}/fullchain.pem s3://st-ssl/letsencrypt/${DOMAIN}/ >/dev/null
        	aws s3 cp ~/letsencrypt/config/live/${DOMAIN}/privkey.pem s3://st-ssl/letsencrypt/${DOMAIN}/ >/dev/null
        	sleep 15s
        	certbot --logs-dir ~/letsencrypt/log/ --config-dir ~/letsencrypt/config/ --work-dir ~/letsencrypt/work/ delete --cert-name ${DOMAIN} >/dev/null
	fi
}


function usage () {
echo -e "
$0 runs in 3 modes as mentioned below. 
Modes:
	init	: to setup initial requirements for running this script. Requires sudo access.
	issue	: to issue letsencrypt ssl.
	renew	: to renew letsencrypt ssl.


$0 (issue|renew) modes requires following arguments. Refer to their description below.
Args: 
	--s3-bucket		: s3 bucket name	
	--domain		: domain name
	--email			: email-ID to receive alerts
	--aws-access-key	: aws iam access key id
	--aws-secret-key	: aws iam secret access key


$0 Usage:
	# for initial setup
		-> sudo bash $0 init
	# to issue ssl
		-> bash $0 issue --domain <domain-name> --s3-bucket <s3-bucket-name> --email <email-id> --aws-access-key <aws-access-key-id> --aws-secret-key <aws-secret-access-key> 
	# to renew ssl
		-> bash $0 renew --domain <domain-name> --s3-bucket <s3-bucket-name> --email <email-id> --aws-access-key <aws-access-key-id> --aws-secret-key <aws-secret-access-key>
"
exit
}


## Execution begins from here
while test $# -gt 0;
do
	case $1 in
		init)
			if [[ $EUID -eq 0 ]]; then
				apt-get update >/dev/null
				apt-get install -y software-properties-common python wget >/dev/null
    				add-apt-repository -y ppa:certbot/certbot >/dev/null
                                apt-get update >/dev/null
			else
				echo -e "- - - - -\n--init option required sudo access.\n Run this script as: sudo $0 <args>\n- - - - -\n"
			fi
			exit
		;;
		issue)
			check_requirements
			shift
			issue_ssl $@
			exit $?
		;;
		renew)
			check_requirements
			shift
			renew_ssl $@
			exit $?
		;;
		*)
			usage
		;;
	esac
done
