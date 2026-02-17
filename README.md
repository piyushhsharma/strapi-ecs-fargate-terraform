# Strapi ECS Fargate Deployment

A complete CI/CD pipeline for deploying a containerized Strapi application on AWS ECS Fargate using Terraform and GitHub Actions.

## Architecture

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   GitHub    │ →  │ GitHub       │ →  │   Amazon    │ →  │   Terraform │ →  │   AWS ECS   │
│   Repository│    │   Actions    │    │     ECR     │    │  Infrastructure│ │  Fargate    │
└─────────────┘    └──────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                                      │
                                                                                      ▼
                                                                            ┌─────────────┐
                                                                            │   AWS RDS   │
                                                                            │ PostgreSQL  │
                                                                            └─────────────┘
```

### Infrastructure Components

- **VPC**: Custom VPC with public and private subnets
- **ECS Cluster**: Fargate-based container orchestration
- **Application Load Balancer**: Public-facing load balancer with health checks
- **RDS PostgreSQL**: Managed database for Strapi
- **ECR**: Container registry for Docker images
- **IAM Roles**: Properly scoped permissions for ECS tasks
- **CloudWatch**: Centralized logging

## Repository Structure

```
.
├── backend/                    # Strapi application
│   ├── config/                # Strapi configuration
│   ├── src/                   # Application source code
│   ├── package.json           # Node.js dependencies
│   └── Dockerfile             # Container definition
├── terraform/                 # Infrastructure as Code
│   ├── main.tf               # AWS provider
│   ├── variables.tf          # Input variables
│   ├── outputs.tf            # Output values
│   ├── vpc.tf                # VPC and networking
│   ├── security.tf            # Security groups
│   ├── ecs.tf                # ECS cluster and service
│   ├── rds.tf                # RDS database
│   ├── ecr.tf                # ECR repository
│   ├── alb.tf                # Load balancer
│   ├── iam.tf                # IAM roles
│   └── versions.tf           # Terraform version constraints
├── .github/
│   └── workflows/
│       └── deploy.yml        # CI/CD pipeline
└── README.md                 # This file
```

## CI/CD Pipeline

The automated deployment process:

1. **Code Push**: Developer pushes to `main` branch
2. **GitHub Actions Trigger**: Workflow starts automatically
3. **Docker Build**: Strapi application is containerized
4. **Image Tagging**: Image is tagged with Git commit SHA
5. **ECR Push**: Docker image is pushed to Amazon ECR
6. **Terraform Apply**: Infrastructure is provisioned/updated
7. **ECS Update**: New container definition is deployed
8. **Health Check**: ALB verifies service availability

## Prerequisites

### AWS Account Setup

1. **Create AWS Account**: Ensure you have an active AWS account
2. **IAM User**: Create an IAM user with the following permissions:
   - `AmazonEC2ContainerRegistryFullAccess`
   - `AmazonECS_FullAccess`
   - `AmazonRDSFullAccess`
   - `AmazonVPCFullAccess`
   - `IAMFullAccess`
   - `CloudWatchLogsFullAccess`
   - `ElasticLoadBalancingFullAccess`

3. **Configure AWS CLI**:
   ```bash
   aws configure
   # Enter your AWS Access Key ID
   # Enter your AWS Secret Access Key
   # Enter default region: us-east-1
   # Enter default output format: json
   ```

### GitHub Secrets

Configure the following repository secrets in GitHub Settings → Secrets and variables → Actions:

- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `DB_PASSWORD`: Secure password for RDS database

## Deployment Steps

### 1. Initial Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd strapi-ecs-fargate-terraform

# Navigate to Terraform directory
cd terraform

# Initialize Terraform
terraform init

# (Optional) Review the execution plan
terraform plan
```

### 2. First Deployment

Push your code to the `main` branch:

```bash
git add .
git commit -m "Initial deployment setup"
git push origin main
```

The GitHub Actions workflow will automatically:
- Build and push the Docker image to ECR
- Provision all AWS infrastructure
- Deploy the Strapi application

### 3. Access Your Application

After deployment, get the ALB DNS name:

```bash
cd terraform
terraform output alb_url
```

Visit the URL to access your Strapi application. The admin panel will be available at `/admin`.

## Redeployments

Every push to the `main` branch triggers an automatic redeployment:

1. Code changes are detected
2. New Docker image is built with commit SHA tag
3. Image is pushed to ECR
4. Terraform updates the ECS task definition
5. ECS performs a blue-green deployment

## Manual Operations

### Destroy Infrastructure

⚠️ **Warning**: This will delete all resources including the database

```bash
cd terraform
terraform destroy -auto-approve \
  -var="db_password=${{ secrets.DB_PASSWORD }}"
```

### Update Specific Resources

```bash
# Update only ECS service
terraform apply -target=aws_ecs_service.this -auto-approve

# Update only task definition
terraform apply -target=aws_ecs_task_definition.strapi -auto-approve
```

## Monitoring and Logs

### CloudWatch Logs

View application logs:

```bash
aws logs tail /ecs/strapi --follow
```

### ECS Service Status

```bash
aws ecs describe-services \
  --cluster strapi-cluster \
  --services strapi-service
```

### RDS Connection

```bash
# Get RDS endpoint
terraform output rds_endpoint

# Connect to database (requires PostgreSQL client)
psql -h <endpoint> -U strapiuser -d strapi
```

## Troubleshooting

### Common Issues

1. **Build Failures**: Check Dockerfile and package.json
2. **Deployment Failures**: Verify AWS credentials and permissions
3. **Database Connection**: Ensure security groups allow RDS access
4. **Load Balancer Health Checks**: Verify Strapi is running on port 1337

### Debug Commands

```bash
# Check ECS task status
aws ecs list-tasks --cluster strapi-cluster

# View task definition
aws ecs describe-task-definition --task-definition strapi-task

# Check ALB target group health
aws elbv2 describe-target-health --target-group-arn <tg-arn>
```

## Security Considerations

- Database password is stored in GitHub secrets
- RDS instance is not publicly accessible
- ECS tasks use least-privilege IAM roles
- All traffic between components stays within the VPC
- RDS storage is encrypted

## Cost Optimization

- Using `db.t3.micro` for RDS (eligible for Free Tier)
- Fargate `vCPU: 0.5, Memory: 1024` minimal configuration
- Auto-scaling can be added for production workloads

## Production Enhancements

For production use, consider adding:

- SSL/TLS certificates with AWS Certificate Manager
- Custom domain names with Route 53
- Auto-scaling for ECS services
- Multi-AZ RDS deployment
- Backup and disaster recovery strategies
- Monitoring and alerting with CloudWatch

## Support

For issues related to:
- **Strapi**: [Strapi Documentation](https://docs.strapi.io/)
- **AWS ECS**: [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- **Terraform**: [Terraform Documentation](https://www.terraform.io/docs/)
- **GitHub Actions**: [GitHub Actions Documentation](https://docs.github.com/en/actions)