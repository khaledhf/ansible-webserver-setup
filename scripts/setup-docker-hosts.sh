#!/bin/bash

# Setup Docker Hosts for Ansible Development
# This script creates Docker containers and configures them for Ansible

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Prerequisites check passed."
}

# Function to generate SSH keys
generate_ssh_keys() {
    print_status "Generating SSH keys for Docker hosts..."
    
    # Create .ssh directory if it doesn't exist
    mkdir -p .ssh
    
    # Generate staging key
    if [ ! -f .ssh/staging_key ]; then
        ssh-keygen -t rsa -b 4096 -f .ssh/staging_key -N "" -C "staging-docker"
        print_success "Generated staging SSH key"
    else
        print_warning "Staging SSH key already exists"
    fi
    
    # Generate production key
    if [ ! -f .ssh/prod_key ]; then
        ssh-keygen -t rsa -b 4096 -f .ssh/prod_key -N "" -C "production-docker"
        print_success "Generated production SSH key"
    else
        print_warning "Production SSH key already exists"
    fi
    
    # Set proper permissions
    chmod 600 .ssh/staging_key
    chmod 600 .ssh/prod_key
    chmod 644 .ssh/staging_key.pub
    chmod 644 .ssh/prod_key.pub
}

# Function to update Docker Compose with SSH keys
update_docker_compose() {
    print_status "Updating Docker Compose with SSH public keys..."
    
    # Read the public keys
    STAGING_PUB_KEY=$(cat .ssh/staging_key.pub)
    PROD_PUB_KEY=$(cat .ssh/prod_key.pub)
    
    # Update docker-compose.yml with the actual public keys
    sed -i "s|ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC...|$STAGING_PUB_KEY|g" docker-compose.yml
    
    print_success "Updated Docker Compose with SSH keys"
}

# Function to start Docker containers
start_containers() {
    print_status "Starting Docker containers..."
    
    # Stop any existing containers
    docker-compose down 2>/dev/null || true
    
    # Start containers
    docker-compose up -d
    
    # Wait for containers to be ready
    print_status "Waiting for containers to be ready..."
    sleep 30
    
    print_success "Docker containers started successfully"
}

# Function to create inventory files
create_inventory_files() {
    print_status "Creating inventory files for Docker hosts..."
    
    # Get container IPs
    WEB_STAGING_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web-staging-01)
    MONITOR_STAGING_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' monitor-staging-01)
    WEB_PROD_01_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web-prod-01)
    WEB_PROD_02_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web-prod-02)
    MONITOR_PROD_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' monitor-prod-01)
    
    # Create staging inventory
    cat > inventories/staging/hosts.yml << EOF
all:
  children:
    webservers:
      hosts:
        web-staging-01:
          ansible_host: $WEB_STAGING_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/staging_key
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
      vars:
        environment: staging
        nginx_worker_processes: 2
        nginx_worker_connections: 512
        ssl_enabled: false
    
    monitoring:
      hosts:
        monitor-staging-01:
          ansible_host: $MONITOR_STAGING_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/staging_key
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
      vars:
        environment: staging
        prometheus_retention_days: 7
        grafana_admin_password: "admin123"
EOF

    # Create production inventory
    cat > inventories/production/hosts.yml << EOF
all:
  children:
    webservers:
      hosts:
        web-prod-01:
          ansible_host: $WEB_PROD_01_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/prod_key
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
        web-prod-02:
          ansible_host: $WEB_PROD_02_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/prod_key
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
      vars:
        environment: production
        nginx_worker_processes: 4
        nginx_worker_connections: 1024
        ssl_enabled: true
    
    monitoring:
      hosts:
        monitor-prod-01:
          ansible_host: $MONITOR_PROD_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/prod_key
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
      vars:
        environment: production
        prometheus_retention_days: 30
        grafana_admin_password: "admin123"
    
    loadbalancers:
      hosts:
        lb-prod-01:
          ansible_host: $WEB_PROD_01_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/prod_key
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
      vars:
        environment: production
        haproxy_stats_port: 8404
EOF

    print_success "Inventory files created successfully"
}

# Function to test connectivity
test_connectivity() {
    print_status "Testing connectivity to Docker hosts..."
    
    # Test staging hosts
    print_status "Testing staging hosts..."
    ansible all -i inventories/staging/hosts.yml -m ping
    
    # Test production hosts
    print_status "Testing production hosts..."
    ansible all -i inventories/production/hosts.yml -m ping
    
    print_success "Connectivity test completed"
}

# Function to show usage information
show_usage_info() {
    print_success "Docker hosts setup completed!"
    echo ""
    echo "🎉 Your development environment is ready!"
    echo ""
    echo "📋 Available hosts:"
    echo "  Staging:"
    echo "    - Web Server: http://localhost:8080"
    echo "    - Monitoring: http://localhost:3000 (Grafana)"
    echo "    - Prometheus: http://localhost:9090"
    echo ""
    echo "  Production:"
    echo "    - Web Server 1: http://localhost:8081"
    echo "    - Web Server 2: http://localhost:8082"
    echo "    - Monitoring: http://localhost:3001 (Grafana)"
    echo "    - Prometheus: http://localhost:9091"
    echo ""
    echo "🚀 Next steps:"
    echo "  1. Deploy to staging: ./scripts/deploy.sh staging"
    echo "  2. Deploy to production: ./scripts/deploy.sh production"
    echo "  3. Access monitoring dashboards"
    echo ""
    echo "🔧 Management commands:"
    echo "  - Start containers: docker-compose up -d"
    echo "  - Stop containers: docker-compose down"
    echo "  - View logs: docker-compose logs -f"
    echo "  - Access container: docker exec -it web-staging-01 bash"
}

# Main function
main() {
    print_status "Setting up Docker hosts for Ansible development..."
    
    # Check prerequisites
    check_prerequisites
    
    # Generate SSH keys
    generate_ssh_keys
    
    # Update Docker Compose
    update_docker_compose
    
    # Start containers
    start_containers
    
    # Create inventory files
    create_inventory_files
    
    # Test connectivity
    test_connectivity
    
    # Show usage information
    show_usage_info
}

# Run main function
main "$@" 