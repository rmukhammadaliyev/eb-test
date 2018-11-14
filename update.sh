#!/bin/bash

set -x

export AWS_DEFAULT_REGION=eu-west-1
secrets=$1
config=.ebextensions/00-eb.config

echo "option_settings:" > $config
echo "  aws:elasticbeanstalk:application:environment:" >> $config

aws --output json secretsmanager get-secret-value \
   --secret-id $secrets | jq --raw-output '.SecretString' | jq -r 'to_entries|map("    "+.key+": "+.value|tostring)|.[]' >> $config


aws --output json secretsmanager get-secret-value \
   --secret-id $secrets | jq --raw-output '.SecretString' | jq -r 'to_entries|map(.key+"="+.value|tostring)|.[]' > vars

chmod +x vars

. ./vars

cp tpl/efs.config .ebextensions/03-efs.config
sed -i '' "s#%EFS_FILE_SYSTEM_ID%#$EFS_FILE_SYSTEM_ID#g" ./.ebextensions/03-efs.config