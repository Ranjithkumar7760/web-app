#!/bin/bash

# Variables
CLUSTER_NAME="your-cluster-name"
SERVICE_NAME="your-service-name"
TASK_DEFINITION_NAME="your-task-def-name"
CONTAINER_NAME="simple-web-app"
DOCKER_USERNAME="your-docker-username" # Replace with your actual Docker Hub username
DOCKER_IMAGE="$DOCKER_USERNAME/simple-web-app:latest"
AWS_REGION="ap-south-1" # Change to your desired region
INSTANCE_TYPE="t2.micro" # Change to your desired instance type
KEY_PAIR_NAME="your-key-pair" # Replace with your key pair name
ECS_AMI_ID="ami-0e472ba40eb589f49" # Replace with the latest ECS optimized AMI ID for your region

# Create an ECS cluster
aws ecs create-cluster --cluster-name $CLUSTER_NAME --region $AWS_REGION

# Create a user data script for the EC2 instance to join the ECS cluster
cat <<EOF > ecs-user-data.txt
#!/bin/bash
echo ECS_CLUSTER=$CLUSTER_NAME >> /etc/ecs/ecs.config
EOF

# Create an EC2 instance and attach it to the cluster
aws ec2 run-instances --image-id $ECS_AMI_ID \
  --count 1 \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_PAIR_NAME \
  --iam-instance-profile Name="ecsInstanceRole" \
  --user-data file://ecs-user-data.txt \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$CLUSTER_NAME-EC2}]" \
  --region $AWS_REGION

# Wait for the EC2 instance to be ready
echo "Waiting for EC2 instance to be in running state..."
aws ec2 wait instance-running --filters Name=tag:Name,Values=$CLUSTER_NAME-EC2 --region $AWS_REGION

# Register the task definition
aws ecs register-task-definition \
  --family $TASK_DEFINITION_NAME \
  --network-mode bridge \
  --container-definitions "[
    {
      \"name\": \"$CONTAINER_NAME\",
      \"image\": \"$DOCKER_IMAGE\",
      \"essential\": true,
      \"portMappings\": [
        {
          \"containerPort\": 80,
          \"hostPort\": 80
        }
      ]
    }
  ]" \
  --requires-compatibilities EC2 \
  --cpu "256" \
  --memory "512" \
  --region $AWS_REGION

# Create an ECS service
aws ecs create-service \
  --cluster $CLUSTER_NAME \
  --service-name $SERVICE_NAME \
  --task-definition $TASK_DEFINITION_NAME \
  --desired-count 1 \
  --launch-type EC2 \
  --region $AWS_REGION

# Update the service to use the new task definition
aws ecs update-service \
  --cluster $CLUSTER_NAME \
  --service $SERVICE_NAME \
  --task-definition $TASK_DEFINITION_NAME \
  --force-new-deployment \
  --region $AWS_REGION

echo "Deployment to ECS complete"
