#!/bin/bash

echo "hello"

# set -e

# readonly EC2_INSTANCE_METADATA_URL="http://169.254.169.254/latest/meta-data"

# function lookup_path_in_instance_metadata() {
#     local -r path=$1
#     curl --silent --show-error --location "$EC2_INSTANCE_METADATA_URL/$path/"
# }

# function get_instance_id() {
#     lookup_path_in_instance_metadata "instance-id"
# }

# function get_instance_type() {
#     lookup_path_in_instance_metadata "instance-type"
# }

# function get_public_ip() {
#     lookup_path_in_instance_metadata "public-ipv4"
# }

# ec2_instance_id=$(get_instance_id)

# exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# sudo yum install -q -y amazon-cloudwatch-agent yum-utils docker systemd-networkd unzip

# sudo service docker start
# sudo usermod -a -G docker ec2-user

# aws s3api get-object --bucket ${compose_bucket} --key ${compose_key} docker-compose.yml
# sudo mkdir -p /etc/indy
# aws s3 cp "s3://${compose_bucket}/${genesis_pool_file_key}" /etc/indy/pool_transactions_genesis
# aws s3 cp "s3://${compose_bucket}/${genesis_domain_file_key}" /etc/indy/domain_transactions_genesis
# sudo chmod 644 /etc/indy/pool_transactions_genesis /etc/indy/domain_transactions_genesis

# sudo mkdir -p /etc/indy2
# aws s3 cp "s3://${compose_bucket}/${genesis_pool_file_key}" /etc/indy2/pool_transactions_genesis
# aws s3 cp "s3://${compose_bucket}/${genesis_domain_file_key}" /etc/indy2/domain_transactions_genesis
# sudo chmod 644 /etc/indy2/pool_transactions_genesis /etc/indy2/domain_transactions_genesis



# $(aws ecr get-login-password --region "${aws_region}" | docker login --username AWS --password-stdin "${account_id}.dkr.ecr.${aws_region}.amazonaws.com")
# echo "*** Getting Secrets ***"
# export INDY_NODE_SEED1=$(aws secretsmanager get-secret-value --secret-id ${node_seed_arn_1} --query SecretString --output text)
# export INDY_NODE_SEED2=$(aws secretsmanager get-secret-value --secret-id ${node_seed_arn_2} --query SecretString --output text)
# export INDY_NODE_NAME1=${node_name_1}
# export INDY_NODE_NAME2=${node_name_2}
# export INDY_NETWORK_NAME=${network_name}
# export INDY_NODE_IP=${node_ip}
# export INDY_CLIENT_IP=${client_ip}
# export AWS_REGION=${aws_region}
# export NODE_IMAGE_NAME=${ecr_node_repo}
# sleep 30
# echo "*** Starting Network ***"

# docker compose -p network up -d --quiet-pull