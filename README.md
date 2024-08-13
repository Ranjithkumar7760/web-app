# web-app

# Simple Web Application Deployment to Amazon ECS

This repository contains a simple web application and instructions to deploy it to Amazon ECS using EC2 instances.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Building the Docker Image](#building-the-docker-image)
- [CI/CD Pipeline](#cicd-pipeline)
- [Deployment](#deployment)
- [Accessing the Web Application](#accessing-the-web-application)
## Prerequisites

1. **AWS CLI**: Ensure you have the AWS CLI installed and configured with your AWS credentials.
   ```bash
   aws configure

#### 4. **Setup**
   - Provide instructions on how to clone the repository and configure the project.

```markdown
## Setup

1. Clone this repository to your local machine.
   ```bash
   git clone https://github.com/Ranjithkumar7760/web-app.git
   cd simple-web-app

Make the deploy.sh script executable.

bash
Copy code
chmod +x deploy.sh



## Building the Docker Image

1. Build the Docker image locally.
   ```bash
   docker build -t simple-web-app .


docker tag simple-web-app:latest your-docker-username/simple-web-app:latest


docker push your-docker-username/simple-web-app:latest


## Deployment

1. Run the `deploy.sh` script to deploy the web application to Amazon ECS using EC2 instances.
   ```bash
   ./deploy.sh


The script will:
Create an ECS cluster.
Launch an EC2 instance and install Docker.
Register a task definition.
Create an ECS service and deploy the task.




Accessing the Web Application

1. Retrieve the public IP address of the EC2 instance:
   ```bash
   aws ec2 describe-instances --filters "Name=tag:Name,Values=your-cluster-name-EC2" --query "Reservations[0].Instances[0].PublicIpAddress" --output text


