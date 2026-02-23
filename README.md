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

## Infrastructure Components

### ECS Configuration
- **Cluster**: `jaspal-strapi-cluster`
- **Service**: `strapi-service`
- **Capacity Provider**: **FARGATE_SPOT** (100% weight)
- **Task Definition**: `strapi-task`
- **Launch Type**: Not used (capacity providers instead)
- **Networking**: Default VPC with public subnets
- **Security**: Dedicated security group for ECS tasks

### Compute Resources
- **Platform**: AWS Fargate
- **CPU**: 512 vCPU
- **Memory**: 1024 MB
- **Container Runtime**: Node.js 18 Alpine
- **Port**: 1337 (Strapi default)

### Storage & Database
- **Database**: PostgreSQL on AWS RDS
- **Persistence**: EFS volumes (if configured)
- **Backups**: Automated RDS snapshots

### CI/CD Pipeline
- **Source Control**: Git with GitHub
- **CI/CD**: GitHub Actions
- **Container Registry**: Docker Hub
- **Infrastructure as Code**: Terraform
- **Deployment Strategy**: Rolling updates with zero downtime

### Security & Networking
- **VPC**: Default AWS VPC
- **Subnets**: 6 subnets across 3 AZs
- **Load Balancer**: Application Load Balancer with HTTPS
- **SSL**: ACM certificate integration
- **IAM**: Least-privilege execution and task roles

### Monitoring & Logging
- **Task-9 Implementation**: Non-interactive Terraform with FARGATE_SPOT
- **Capacity Strategy**: Spot instances with automatic fallback
- **Variables**: Fully automated via terraform.tfvars
- **No CloudWatch**: Removed all CloudWatch dependencies
- **Cost Optimization**: Spot instances for cost savings

## Key Features

### ✅ TASK-9: Non-Interactive Terraform with FARGATE_SPOT
- **Zero Prompts**: Terraform runs completely non-interactively
- **Spot Instances**: ECS service uses FARGATE_SPOT capacity provider
- **Cost Savings**: Up to 70% savings compared to on-demand
- **No CloudWatch**: Removed all CloudWatch logging and monitoring
- **Idempotent**: Multiple apply operations work without changes
- **Automated Variables**: All inputs defined in terraform.tfvars

### Previous Implementations
- **TASK-8**: CloudWatch logging and monitoring (removed in TASK-9)
- **TASK-7**: ECS Fargate deployment with ALB integration
- **TASK-6**: GitHub Actions CI/CD pipeline
- **TASK-5**: RDS PostgreSQL database configuration

## Deployment Process

### Prerequisites
1. AWS CLI configured with appropriate permissions
2. Docker Hub access credentials
3. GitHub repository with appropriate secrets

### Deployment Steps
1. **Code Commit**: Push to main branch
2. **GitHub Actions Trigger**: Automatic CI/CD pipeline
3. **Build Phase**: Docker image built and pushed to registry
4. **Infrastructure**: Terraform applies changes non-interactively
5. **Service Update**: ECS service updated with new task definition
6. **Health Checks**: ALB verifies service availability

### Cost Optimization
- **Spot Instances**: FARGATE_SPOT with weight = 1
- **Fallback**: Automatic interruption handling
- **Savings**: 60-70% cost reduction vs on-demand
- **Reliability**: Multi-AZ deployment for high availability

## Development Workflow

### Local Development
```bash
# Initialize Terraform
cd terraform
terraform init

# Plan changes (non-interactive)
terraform plan

# Apply changes
terraform apply -auto-approve
```

### CI/CD Pipeline
```yaml
# GitHub Actions automatically:
# - Builds Docker image
# - Pushes to registry
# - Runs Terraform non-interactively
# - Updates ECS service
```

## Security Considerations

### IAM Roles
- **Execution Role**: Minimal permissions for ECS tasks
- **Task Role**: Application-specific permissions only
- **No CloudWatch**: Removed all CloudWatch permissions

### Network Security
- **VPC**: Default AWS VPC with private subnets
- **Security Groups**: Least-privilege access
- **ALB**: HTTPS termination with ACM certificates
- **Ingress**: Only necessary ports (1337 for Strapi)

### Data Protection
- **RDS**: Encrypted storage with automated backups
- **Secrets**: Stored in GitHub Secrets, not in code
- **Environment**: Production-ready configuration

## Troubleshooting

### Common Issues
1. **ECS Service Not Updating**: Check capacity provider configuration
2. **Task Failures**: Verify task definition and IAM roles
3. **Network Issues**: Confirm security group and VPC configuration
4. **Database Connection**: Validate RDS connectivity and credentials

### Debug Commands
```bash
# Check ECS service status
aws ecs describe-services --cluster jaspal-strapi-cluster

# View task definitions
aws ecs describe-task-definition --task-definition strapi-task

# Check running tasks
aws ecs list-tasks --cluster jaspal-strapi-cluster
```

## Configuration Files

### Terraform Structure
```
terraform/
├── main.tf              # Main configuration with ECS module
├── variables.tf          # Input variables with defaults
├── outputs.tf           # Output values
├── providers.tf         # AWS provider configuration
├── terraform.tfvars     # Variable values (non-interactive)
└── modules/
    └── ecs/
        ├── main.tf      # ECS resources with FARGATE_SPOT
        ├── variables.tf  # Module variables
        └── outputs.tf   # Module outputs
```

### Key Configuration Files
- **`terraform/terraform.tfvars`**: All variables defined for non-interactive runs
- **`terraform/modules/ecs/main.tf`**: ECS service with FARGATE_SPOT capacity provider
- **`terraform/variables.tf`**: Variables with defaults and sensitive flag

## Environment Variables

### Required Variables
- `image_url`: Docker image for Strapi application
- `db_password`: Database password (marked as sensitive)

### GitHub Secrets
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `DOCKERHUB_USERNAME`: Docker Hub username
- `DOCKERHUB_PASSWORD`: Docker Hub password
- `DB_PASSWORD`: Database password

## Performance & Scaling

### Auto Scaling
- **Desired Count**: 1 (configurable)
- **Capacity Provider**: FARGATE_SPOT for cost optimization
- **Health Checks**: ALB-based health verification
- **Rolling Updates**: Zero-downtime deployments

### Monitoring
- **Task Status**: ECS service health monitoring
- **Resource Utilization**: CloudWatch metrics (if re-enabled)
- **Cost Tracking**: Spot instance usage monitoring

## Compliance & Standards

### AWS Best Practices
- ✅ Infrastructure as Code
- ✅ Least-privilege IAM roles
- ✅ Multi-AZ deployment
- ✅ Encrypted data storage
- ✅ Automated backups

### Security Standards
- ✅ No hardcoded secrets
- ✅ HTTPS enforcement
- ✅ Network segmentation
- ✅ Regular security updates

## Version History

### Current Implementation
- **Version**: TASK-9 Complete
- **Date**: February 2026
- **Features**: FARGATE_SPOT, non-interactive Terraform
- **Status**: Production ready

### Previous Versions
- **TASK-8**: CloudWatch logging and monitoring
- **TASK-7**: ECS Fargate with ALB
- **TASK-6**: GitHub Actions CI/CD
- **TASK-5**: RDS PostgreSQL integration

## Support

### Getting Help
1. Check ECS service status in AWS Console
2. Review GitHub Actions workflow logs
3. Verify Terraform state with `terraform show`
4. Validate configuration with `terraform validate`

### Emergency Procedures
1. **Service Recovery**: Manual ECS service restart if needed
2. **Rollback**: Previous task definition deployment
3. **Database Access**: Direct RDS connection for diagnostics
4. **Infrastructure Reset**: Terraform state recovery from backup

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