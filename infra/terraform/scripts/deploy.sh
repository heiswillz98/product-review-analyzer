set -e

# 🚀 Determine the absolute path to the repo root
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV=$1

if [ -z "$ENV" ]; then
  echo "❌ Usage: ./destroy.sh <env>"
  exit 1
fi

ENV_DIR="$ROOT_DIR/environments/$ENV"

if [ ! -d "$ENV_DIR" ]; then
  echo "❌ Environment directory '$ENV_DIR' not found!"
  exit 1
fi

cd "$ENV_DIR"


echo "🚀 Starting EKS cluster deployment..."

# Step 1: Initialize Terraform
echo "⚙️  Initializing Terraform..."
terraform init

# Step 2: Create VPC and IAM resources first
echo "🏗️  Creating VPC and IAM resources..."
terraform apply -target=module.vpc -target=module.iam -auto-approve

# Wait for resources to be ready
echo "⏳ Waiting for VPC and IAM resources to be ready..."
sleep 10

# Step 3: Create EKS cluster
echo "🎯 Creating EKS cluster..."
terraform apply -target=module.eks -auto-approve

# Wait for cluster to be ready
echo "⏳ Waiting for EKS cluster to be ready..."
sleep 30

# Step 4: Create node group
echo "🖥️  Creating node group..."
terraform apply -target=module.node_group -auto-approve

# Step 5: Apply any remaining resources
echo "🔧 Applying remaining resources..."
terraform apply -auto-approve

echo "✅ EKS cluster deployed successfully!"
echo "📋 Cluster details:"
terraform output