# 🖥️ Host Setup Guide

This guide shows you how to create hosts for your enhanced DevOps infrastructure using different methods.

## 🐳 **Option 1: Docker Containers (Recommended for Development)**

### **Prerequisites**
- Docker
- Docker Compose

### **Quick Setup**
```bash
# Make scripts executable
chmod +x scripts/setup-docker-hosts.sh
chmod +x scripts/deploy.sh

# Run the setup script
./scripts/setup-docker-hosts.sh
```

### **What it creates:**
- **Staging Environment:**
  - `web-staging-01` (192.168.2.10) - Web server
  - `monitor-staging-01` (192.168.2.20) - Monitoring server
- **Production Environment:**
  - `web-prod-01` (192.168.1.10) - Web server 1
  - `web-prod-02` (192.168.1.11) - Web server 2
  - `monitor-prod-01` (192.168.1.20) - Monitoring server

### **Access Points:**
- Staging Web: http://localhost:8080
- Staging Grafana: http://localhost:3000
- Staging Prometheus: http://localhost:9090
- Production Web 1: http://localhost:8081
- Production Web 2: http://localhost:8082
- Production Grafana: http://localhost:3001
- Production Prometheus: http://localhost:9091

### **Management:**
```bash
# Start containers
docker-compose up -d

# Stop containers
docker-compose down

# View logs
docker-compose logs -f

# Access container
docker exec -it web-staging-01 bash
```

## 🖥️ **Option 2: Vagrant Virtual Machines**

### **Prerequisites**
- Vagrant
- VirtualBox

### **Quick Setup**
```bash
# Make scripts executable
chmod +x scripts/setup-vagrant-hosts.sh

# Run the setup script
./scripts/setup-vagrant-hosts.sh
```

### **Management:**
```bash
# Start VMs
vagrant up

# Stop VMs
vagrant halt

# Destroy VMs
vagrant destroy

# View status
vagrant status

# Access VM
vagrant ssh web-staging
```

## ☁️ **Option 3: Cloud Providers**

### **AWS EC2 Setup**

#### **Using AWS CLI**
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS
aws configure

# Create security group
aws ec2 create-security-group \
    --group-name ansible-dev \
    --description "Security group for Ansible development"

# Add rules
aws ec2 authorize-security-group-ingress \
    --group-name ansible-dev \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-name ansible-dev \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-name ansible-dev \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# Launch instances
aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --count 1 \
    --instance-type t2.micro \
    --key-name your-key-pair \
    --security-groups ansible-dev \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-staging}]'
```

#### **Using Terraform**
```hcl
# main.tf
provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "ansible_dev" {
  name        = "ansible-dev"
  description = "Security group for Ansible development"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_staging" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  key_name      = "your-key-pair"

  vpc_security_group_ids = [aws_security_group.ansible_dev.id]

  tags = {
    Name = "web-staging"
  }
}
```

### **DigitalOcean Setup**

#### **Using doctl CLI**
```bash
# Install doctl
snap install doctl

# Authenticate
doctl auth init

# Create droplets
doctl compute droplet create web-staging \
    --size s-1vcpu-1gb \
    --image ubuntu-20-04-x64 \
    --region nyc1 \
    --ssh-keys your-ssh-key-id

doctl compute droplet create monitor-staging \
    --size s-1vcpu-1gb \
    --image ubuntu-20-04-x64 \
    --region nyc1 \
    --ssh-keys your-ssh-key-id
```

### **Google Cloud Platform**

#### **Using gcloud CLI**
```bash
# Install gcloud
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Authenticate
gcloud auth login

# Set project
gcloud config set project your-project-id

# Create instances
gcloud compute instances create web-staging \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=http-server,https-server

gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --target-tags=http-server \
    --source-ranges=0.0.0.0/0
```

## 🔧 **Option 4: Local Development with Multipass**

### **Installation**
```bash
# Install Multipass
sudo snap install multipass

# Create instances
multipass launch --name web-staging --memory 1G --disk 5G
multipass launch --name monitor-staging --memory 1G --disk 5G
multipass launch --name web-prod-01 --memory 2G --disk 10G
multipass launch --name web-prod-02 --memory 2G --disk 10G
multipass launch --name monitor-prod --memory 2G --disk 10G

# Get IP addresses
multipass list
```

### **Setup SSH Access**
```bash
# Generate SSH keys
ssh-keygen -t rsa -b 4096 -f ~/.ssh/staging_key -N ""
ssh-keygen -t rsa -b 4096 -f ~/.ssh/prod_key -N ""

# Copy keys to instances
multipass exec web-staging -- bash -c "mkdir -p /home/ubuntu/.ssh && echo '$(cat ~/.ssh/staging_key.pub)' > /home/ubuntu/.ssh/authorized_keys"
multipass exec monitor-staging -- bash -c "mkdir -p /home/ubuntu/.ssh && echo '$(cat ~/.ssh/staging_key.pub)' > /home/ubuntu/.ssh/authorized_keys"
multipass exec web-prod-01 -- bash -c "mkdir -p /home/ubuntu/.ssh && echo '$(cat ~/.ssh/prod_key.pub)' > /home/ubuntu/.ssh/authorized_keys"
multipass exec web-prod-02 -- bash -c "mkdir -p /home/ubuntu/.ssh && echo '$(cat ~/.ssh/prod_key.pub)' > /home/ubuntu/.ssh/authorized_keys"
multipass exec monitor-prod -- bash -c "mkdir -p /home/ubuntu/.ssh && echo '$(cat ~/.ssh/prod_key.pub)' > /home/ubuntu/.ssh/authorized_keys"
```

## 📋 **Inventory Configuration**

After setting up your hosts, update the inventory files:

### **For Cloud/Remote Hosts**
```yaml
# inventories/staging/hosts.yml
all:
  children:
    webservers:
      hosts:
        web-staging-01:
          ansible_host: YOUR_STAGING_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/staging_key
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
```

### **For Local Development**
```yaml
# inventories/staging/hosts.yml
all:
  children:
    webservers:
      hosts:
        web-staging-01:
          ansible_host: 192.168.2.10  # Docker/Vagrant IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/staging_key
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
```

## 🚀 **Deployment**

Once your hosts are set up:

```bash
# Deploy to staging
./scripts/deploy.sh staging

# Deploy to production
./scripts/deploy.sh production

# Test connectivity
ansible all -i inventories/staging/hosts.yml -m ping
```

## 💡 **Recommendations**

### **For Development:**
- **Docker**: Fastest setup, good for testing
- **Vagrant**: More realistic environment, good for learning

### **For Production:**
- **Cloud Providers**: AWS, DigitalOcean, GCP
- **On-premises**: Physical servers or VMs

### **For Learning:**
- **Multipass**: Lightweight, good for Ubuntu development
- **Docker**: Quick iteration and testing

## 🔒 **Security Considerations**

1. **SSH Keys**: Always use SSH key authentication
2. **Firewall**: Configure security groups/firewalls properly
3. **Updates**: Keep base images updated
4. **Access Control**: Limit SSH access to necessary IPs
5. **Monitoring**: Enable logging and monitoring

## 📚 **Additional Resources**

- [Docker Documentation](https://docs.docker.com/)
- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [DigitalOcean API Documentation](https://developers.digitalocean.com/)
- [Google Cloud Compute Documentation](https://cloud.google.com/compute/docs) 