#!/bin/bash

# Setup Vagrant Hosts for Ansible Development
# This script creates Vagrant VMs and configures them for Ansible

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
    
    # Check if Vagrant is installed
    if ! command -v vagrant &> /dev/null; then
        print_error "Vagrant is not installed. Please install Vagrant first."
        exit 1
    fi
    
    # Check if VirtualBox is installed
    if ! command -v VBoxManage &> /dev/null; then
        print_error "VirtualBox is not installed. Please install VirtualBox first."
        exit 1
    fi
    
    print_success "Prerequisites check passed."
}

# Function to generate SSH keys
generate_ssh_keys() {
    print_status "Generating SSH keys for Vagrant hosts..."
    
    # Create .ssh directory if it doesn't exist
    mkdir -p .ssh
    
    # Generate staging key
    if [ ! -f .ssh/staging_key ]; then
        ssh-keygen -t rsa -b 4096 -f .ssh/staging_key -N "" -C "staging-vagrant"
        print_success "Generated staging SSH key"
    else
        print_warning "Staging SSH key already exists"
    fi
    
    # Generate production key
    if [ ! -f .ssh/prod_key ]; then
        ssh-keygen -t rsa -b 4096 -f .ssh/prod_key -N "" -C "production-vagrant"
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

# Function to copy SSH keys to VMs
copy_ssh_keys() {
    print_status "Copying SSH keys to Vagrant VMs..."
    
    # Copy staging key to staging VMs
    print_status "Copying keys to staging VMs..."
    vagrant ssh web-staging -c "mkdir -p /home/ubuntu/.ssh && echo '$(cat .ssh/staging_key.pub)' > /home/ubuntu/.ssh/authorized_keys && chown -R ubuntu:ubuntu /home/ubuntu/.ssh && chmod 700 /home/ubuntu/.ssh && chmod 600 /home/ubuntu/.ssh/authorized_keys" 2>/dev/null || true
    
    vagrant ssh monitor-staging -c "mkdir -p /home/ubuntu/.ssh && echo '$(cat .ssh/staging_key.pub)' > /home/ubuntu/.ssh/authorized_keys && chown -R ubuntu:ubuntu /home/ubuntu/.ssh && chmod 700 /home/ubuntu/.ssh && chmod 600 /home/ubuntu/.ssh/authorized_keys" 2>/dev/null || true
    
    # Copy production key to production VMs
    print_status "Copying keys to production VMs..."
    vagrant ssh web-prod-01 -c "mkdir -p /home/ubuntu/.ssh && echo '$(cat .ssh/prod_key.pub)' > /home/ubuntu/.ssh/authorized_keys && chown -R ubuntu:ubuntu /home/ubuntu/.ssh && chmod 700 /home/ubuntu/.ssh && chmod 600 /home/ubuntu/.ssh/authorized_keys" 2>/dev/null || true
    
    vagrant ssh web-prod-02 -c "mkdir -p /home/ubuntu/.ssh && echo '$(cat .ssh/prod_key.pub)' > /home/ubuntu/.ssh/authorized_keys && chown -R ubuntu:ubuntu /home/ubuntu/.ssh && chmod 700 /home/ubuntu/.ssh && chmod 600 /home/ubuntu/.ssh/authorized_keys" 2>/dev/null || true
    
    vagrant ssh monitor-prod -c "mkdir -p /home/ubuntu/.ssh && echo '$(cat .ssh/prod_key.pub)' > /home/ubuntu/.ssh/authorized_keys && chown -R ubuntu:ubuntu /home/ubuntu/.ssh && chmod 700 /home/ubuntu/.ssh && chmod 600 /home/ubuntu/.ssh/authorized_keys" 2>/dev/null || true
    
    print_success "SSH keys copied to all VMs"
}

# Function to start Vagrant VMs
start_vms() {
    print_status "Starting Vagrant VMs..."
    
    # Destroy existing VMs if they exist
    vagrant destroy -f 2>/dev/null || true
    
    # Start all VMs
    vagrant up
    
    # Wait for VMs to be ready
    print_status "Waiting for VMs to be ready..."
    sleep 60
    
    print_success "Vagrant VMs started successfully"
}

# Function to create inventory files
create_inventory_files() {
    print_status "Creating inventory files for Vagrant hosts..."
    
    # Create staging inventory
    cat > inventories/staging/hosts.yml << EOF
all:
  children:
    webservers:
      hosts:
        web-staging-01:
          ansible_host: 192.168.2.10
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
          ansible_host: 192.168.2.20
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
          ansible_host: 192.168.1.10
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/prod_key
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
        web-prod-02:
          ansible_host: 192.168.1.11
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
          ansible_host: 192.168.1.20
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
          ansible_host: 192.168.1.10
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
    print_status "Testing connectivity to Vagrant hosts..."
    
    # Wait a bit more for SSH to be fully ready
    sleep 30
    
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
    print_success "Vagrant hosts setup completed!"
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
    echo "  - Start VMs: vagrant up"
    echo "  - Stop VMs: vagrant halt"
    echo "  - Destroy VMs: vagrant destroy"
    echo "  - View VM status: vagrant status"
    echo "  - Access VM: vagrant ssh web-staging"
    echo ""
    echo "💡 Tips:"
    echo "  - VMs use private networks: 192.168.1.x (prod), 192.168.2.x (staging)"
    echo "  - SSH keys are automatically configured"
    echo "  - All VMs have the 'ubuntu' user with sudo access"
}

# Main function
main() {
    print_status "Setting up Vagrant hosts for Ansible development..."
    
    # Check prerequisites
    check_prerequisites
    
    # Generate SSH keys
    generate_ssh_keys
    
    # Start VMs
    start_vms
    
    # Copy SSH keys
    copy_ssh_keys
    
    # Create inventory files
    create_inventory_files
    
    # Test connectivity
    test_connectivity
    
    # Show usage information
    show_usage_info
}

# Run main function
main "$@" 