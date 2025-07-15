#!/bin/bash

# Enhanced DevOps Deployment Script
# Usage: ./scripts/deploy.sh [staging|production] [--dry-run]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Ansible is installed
    if ! command -v ansible &> /dev/null; then
        print_error "Ansible is not installed. Please install Ansible first."
        exit 1
    fi
    
    # Check if inventory exists
    if [ ! -f "inventories/$1/hosts.yml" ]; then
        print_error "Inventory file inventories/$1/hosts.yml not found."
        exit 1
    fi
    
    # Check if playbook exists
    if [ ! -f "playbooks/deploy-$1.yml" ]; then
        print_error "Playbook file playbooks/deploy-$1.yml not found."
        exit 1
    fi
    
    print_success "Prerequisites check passed."
}

# Function to run pre-deployment checks
pre_deployment_checks() {
    print_status "Running pre-deployment checks..."
    
    # Syntax check
    print_status "Checking playbook syntax..."
    ansible-playbook --syntax-check "playbooks/deploy-$1.yml"
    
    # Dry run if requested
    if [[ "$2" == "--dry-run" ]]; then
        print_status "Running dry-run..."
        ansible-playbook --check "playbooks/deploy-$1.yml" -i "inventories/$1/hosts.yml"
        print_success "Dry-run completed successfully."
        exit 0
    fi
    
    print_success "Pre-deployment checks completed."
}

# Function to deploy
deploy() {
    local environment=$1
    local dry_run=$2
    
    print_status "Starting deployment to $environment environment..."
    
    # Set additional variables based on environment
    local extra_vars=""
    if [ "$environment" = "production" ]; then
        extra_vars="--extra-vars 'environment=production'"
        print_warning "Deploying to PRODUCTION environment!"
        read -p "Are you sure you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Deployment cancelled."
            exit 0
        fi
    fi
    
    # Run the deployment
    print_status "Executing Ansible playbook..."
    eval "ansible-playbook -i inventories/$environment/hosts.yml playbooks/deploy-$environment.yml $extra_vars"
    
    if [ $? -eq 0 ]; then
        print_success "Deployment to $environment completed successfully!"
        
        # Post-deployment health checks
        print_status "Running post-deployment health checks..."
        run_health_checks "$environment"
    else
        print_error "Deployment to $environment failed!"
        exit 1
    fi
}

# Function to run health checks
run_health_checks() {
    local environment=$1
    
    # Get the first webserver host from inventory
    local host=$(ansible-inventory -i "inventories/$environment/hosts.yml" --list | jq -r '.webservers.hosts | keys | .[0]' 2>/dev/null || echo "")
    
    if [ -n "$host" ]; then
        print_status "Running health checks on $host..."
        
        # Check web server health
        if curl -f -s "http://$host/health" > /dev/null 2>&1; then
            print_success "Web server health check passed"
        else
            print_warning "Web server health check failed"
        fi
        
        # Check monitoring if available
        if curl -f -s "http://$host:9090/-/healthy" > /dev/null 2>&1; then
            print_success "Prometheus health check passed"
        else
            print_warning "Prometheus health check failed"
        fi
        
        if curl -f -s "http://$host:3000/api/health" > /dev/null 2>&1; then
            print_success "Grafana health check passed"
        else
            print_warning "Grafana health check failed"
        fi
    else
        print_warning "Could not determine host for health checks"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [staging|production] [--dry-run]"
    echo ""
    echo "Options:"
    echo "  staging     Deploy to staging environment"
    echo "  production  Deploy to production environment"
    echo "  --dry-run   Run deployment in dry-run mode (no changes made)"
    echo ""
    echo "Examples:"
    echo "  $0 staging"
    echo "  $0 production"
    echo "  $0 staging --dry-run"
}

# Main script logic
main() {
    # Check if environment is provided
    if [ $# -eq 0 ]; then
        print_error "No environment specified."
        show_usage
        exit 1
    fi
    
    local environment=$1
    local dry_run=$2
    
    # Validate environment
    if [[ "$environment" != "staging" && "$environment" != "production" ]]; then
        print_error "Invalid environment: $environment"
        show_usage
        exit 1
    fi
    
    # Check prerequisites
    check_prerequisites "$environment"
    
    # Run pre-deployment checks
    pre_deployment_checks "$environment" "$dry_run"
    
    # Deploy
    deploy "$environment" "$dry_run"
}

# Run main function with all arguments
main "$@" 