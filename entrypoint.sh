#!/bin/sh

set -e


mkdir -p ~/.aws

touch ~/.aws/credentials

echo "[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" > ~/.aws/credentials


CURRENT_STATUS=$(aws autoscaling   describe-auto-scaling-groups  --auto-scaling-group-name $ASG_NAME | jq -r  '.AutoScalingGroups[0]')
ORIGINAL_MAX=$(echo $CURRENT_STATUS | jq -r  '.MaxSize')
ORIGINAL_MIN=$(echo $CURRENT_STATUS | jq -r  '.MinSize')
ORIGINAL_CAPACITY=$(echo $CURRENT_STATUS | jq -r  '.DesiredCapacity')


aws autoscaling   update-auto-scaling-group  --auto-scaling-group-name $ASG_NAME --desired-capacity $DESIRED_INSTANCES --max-size $MAX_INSTANCES
CURRENT_CAPACITY="$ORIGINAL_CAPACITY"
while [ "$CURRENT_CAPACITY" != "$DESIRED_INSTANCES" ]; do
    sleep 5
    CURRENT_CAPACITY=$(aws autoscaling   describe-auto-scaling-groups  --auto-scaling-group-name $ASG_NAME | jq  '.AutoScalingGroups[0] | [.Instances[] | select(.HealthStatus == "Healthy" and .LifecycleState == "InService")] | length')
    echo "Current capacity: $CURRENT_CAPACITY"
done
rm -rf ~/.aws

echo "::set-output name=original_max::$ORIGINAL_MAX"
echo "::set-output name=original_min::$ORIGINAL_MIN"
echo "::set-output name=original_desired::$ORIGINAL_CAPACITY"