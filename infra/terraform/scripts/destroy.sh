# #!/bin/bash
# set -e

# ENV=$1

# if [ -z "$ENV" ]; then
#   echo "❌ Usage: ./destroy.sh <env>"
#   exit 1
# fi

# ENV_DIR="environments/$ENV"

# if [ ! -d "$ENV_DIR" ]; then
#   echo "❌ Environment directory '$ENV_DIR' not found!"
#   exit 1
# fi

# cd "$ENV_DIR"

# echo "🔥 Starting EKS cluster destruction..."

# # Step 1: Scale down node group to 0
# echo "📉 Scaling down node group..."
# terraform apply -target=module.node_group.aws_eks_node_group.this \
#   -var="desired_capacity=0" \
#   -var="min_capacity=0" \
#   -auto-approve

# # Wait for scaling to complete
# echo "⏳ Waiting for nodes to terminate..."
# sleep 60

# # Step 2: Destroy node group
# echo "🗑️  Destroying node group..."
# terraform destroy -target=module.node_group.aws_eks_node_group.this -auto-approve

# # Wait for node group destruction
# echo "⏳ Waiting for node group cleanup..."
# sleep 30

# # Step 3: Destroy EKS cluster
# echo "🗑️  Destroying EKS cluster..."
# terraform destroy -target=module.eks.aws_eks_cluster.this -auto-approve

# # Wait for cluster destruction
# echo "⏳ Waiting for cluster cleanup..."
# sleep 30

# # Step 4: Destroy everything else
# echo "🗑️  Destroying remaining resources..."
# terraform destroy -auto-approve

# echo "✅ EKS cluster destroyed successfully!"


#!/bin/bash
set -e

# Get the directory where this script is located, then go up one level to get project root
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

echo "🔥 Starting EKS cluster destruction from: $ENV_DIR"

# Function to check if resource exists
check_resource() {
  local resource_type=$1
  local resource_name=$2
  terraform state show "$resource_type.$resource_name" >/dev/null 2>&1
}

# Function to wait for resource deletion
wait_for_deletion() {
  local resource_type=$1
  local resource_name=$2
  local max_attempts=30
  local attempt=1
  
  echo "⏳ Waiting for $resource_type.$resource_name to be deleted..."
  
  while [ $attempt -le $max_attempts ]; do
    if ! check_resource "$resource_type" "$resource_name"; then
      echo "✅ $resource_type.$resource_name deleted successfully"
      return 0
    fi
    echo "   Attempt $attempt/$max_attempts - still waiting..."
    sleep 10
    ((attempt++))
  done
  
  echo "⚠️  Timeout waiting for $resource_type.$resource_name deletion"
  return 1
}

# Function to force cleanup AWS resources
cleanup_aws_resources() {
  echo "🧹 Attempting to cleanup AWS resources manually..."
  
  # Get cluster name from terraform output if available
  CLUSTER_NAME=$(terraform output -json 2>/dev/null | jq -r '.cluster_name.value // empty' || echo "")
  
  if [ -n "$CLUSTER_NAME" ]; then
    echo "🔍 Found cluster name: $CLUSTER_NAME"
    
    # Delete any remaining node groups
    echo "🗑️  Checking for remaining node groups..."
    aws eks list-nodegroups --cluster-name "$CLUSTER_NAME" --query 'nodegroups[]' --output text 2>/dev/null | while read -r nodegroup; do
      if [ -n "$nodegroup" ]; then
        echo "   Deleting node group: $nodegroup"
        aws eks delete-nodegroup --cluster-name "$CLUSTER_NAME" --nodegroup-name "$nodegroup" || true
      fi
    done
    
    # Wait for node groups to be deleted
    echo "⏳ Waiting for node groups to be fully deleted..."
    sleep 60
  fi
  
  # Clean up any remaining ENIs in the VPC
  VPC_ID=$(terraform output -json 2>/dev/null | jq -r '.vpc_id.value // empty' || echo "")
  if [ -n "$VPC_ID" ]; then
    echo "🔍 Found VPC ID: $VPC_ID"
    echo "🧹 Cleaning up ENIs in VPC..."
    
    # Delete ENIs that might be blocking subnet deletion
    aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=$VPC_ID" --query 'NetworkInterfaces[?Status==`available`].NetworkInterfaceId' --output text 2>/dev/null | while read -r eni; do
      if [ -n "$eni" ]; then
        echo "   Deleting ENI: $eni"
        aws ec2 delete-network-interface --network-interface-id "$eni" || true
      fi
    done
    
    sleep 30
  fi
}

# Step 1: Scale down node group to 0
echo "📉 Scaling down node group..."
if check_resource "module.node_group.aws_eks_node_group" "this"; then
  terraform apply -target=module.node_group.aws_eks_node_group.this \
    -var="desired_capacity=0" \
    -var="min_capacity=0" \
    -auto-approve || true
  
  # Wait for scaling to complete
  echo "⏳ Waiting for nodes to terminate..."
  sleep 60
else
  echo "ℹ️  Node group not found in state, skipping scale down"
fi

# Step 2: Destroy node group
echo "🗑️  Destroying node group..."
if check_resource "module.node_group.aws_eks_node_group" "this"; then
  terraform destroy -target=module.node_group.aws_eks_node_group.this -auto-approve || true
  wait_for_deletion "module.node_group.aws_eks_node_group" "this" || true
else
  echo "ℹ️  Node group not found in state, skipping"
fi

# Step 3: Destroy EKS cluster
echo "🗑️  Destroying EKS cluster..."
if check_resource "module.eks.aws_eks_cluster" "this"; then
  terraform destroy -target=module.eks.aws_eks_cluster.this -auto-approve || true
  wait_for_deletion "module.eks.aws_eks_cluster" "this" || true
else
  echo "ℹ️  EKS cluster not found in state, skipping"
fi

# Step 4: Manual cleanup if needed
cleanup_aws_resources

# Step 5: Destroy everything else with retries
echo "🗑️  Destroying remaining resources..."
max_retries=3
retry_count=0

while [ $retry_count -lt $max_retries ]; do
  echo "   Attempt $((retry_count + 1))/$max_retries"
  
  if terraform destroy -auto-approve; then
    echo "✅ EKS cluster destroyed successfully!"
    exit 0
  else
    echo "⚠️  Destroy attempt failed, retrying in 60 seconds..."
    retry_count=$((retry_count + 1))
    
    if [ $retry_count -lt $max_retries ]; then
      # Try manual cleanup again
      cleanup_aws_resources
      sleep 60
    fi
  fi
done

echo "❌ Failed to destroy all resources after $max_retries attempts"
echo "💡 You may need to manually clean up remaining resources in the AWS console"
echo "🔍 Check for:"
echo "   - Load balancers created by Kubernetes services"
echo "   - Security groups with dependencies"
echo "   - ENIs not properly cleaned up"
echo "   - EBS volumes from persistent volume claims"

exit 1