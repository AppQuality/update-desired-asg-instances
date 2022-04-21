#!/bin/sh

set -e

# if [ -z "$S3_BUCKET" ]; then
#   echo "S3_BUCKET is not set. Quitting."
#   exit 1
# fi
# if [ -z "$AWS_ACCESS_KEY_ID" ]; then
#   echo "AWS_ACCESS_KEY_ID is not set. Quitting."
#   exit 1
# fi
# if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
#   echo "AWS_SECRET_ACCESS_KEY is not set. Quitting."
#   exit 1
# fi

# if [-z "$FILE"]; then
#   echo "FILE is not set. Quitting"
#   exit 1
# fi

# if [ -z "$AWS_REGION"]; then
#   AWS_REGION="us-east-1"
# fi

mkdir -p ~/.aws

touch ~/.aws/credentials

echo "[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" > ~/.aws/credentials

aws autoscaling   update-auto-scaling-group  --auto-scaling-group-name $ASG_NAME --desired-capacity $CAPACITY --max-size $CAPACITY

CURRENT_CAPACITY=0
while [ "$CURRENT_CAPACITY" != "$CAPACITY" ]; do
    CURRENT_CAPACITY=$(aws autoscaling   describe-auto-scaling-groups  --auto-scaling-group-name $ASG_NAME | jq  '.AutoScalingGroups[0] | [.Instances[] | select(.HealthStatus == "Healthy")] | length')
    echo "Current capacity: $CURRENT_CAPACITY"
    sleep 5
done
rm -rf ~/.aws
