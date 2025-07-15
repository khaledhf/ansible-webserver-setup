# 🚀 Quick Start Guide

Get your enhanced DevOps infrastructure running in minutes!

## 📋 Prerequisites

- **For Docker**: Docker and Docker Compose
- **For Vagrant**: Vagrant and VirtualBox
- **For Cloud**: AWS CLI, DigitalOcean CLI, or Google Cloud CLI
- **Always**: Ansible 2.12+

## ⚡ **Option 1: Docker (Fastest - 5 minutes)**

### **Step 1: Install Docker**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose

# macOS
brew install docker docker-compose

# Windows
# Download Docker Desktop from https://www.docker.com/products/docker-desktop
```

### **Step 2: Setup Environment**
```bash
# Clone your repository
git clone <your-repo>
cd ansible-webserver-setup

# Make scripts executable
chmod +x scripts/setup-docker-hosts.sh
chmod +x scripts/deploy.sh

# Run the setup
./scripts/setup-docker-hosts.sh
```

### **Step 3: Deploy**
```bash
# Deploy to staging
./scripts/deploy.sh staging

# Deploy to production
./scripts/deploy.sh production
```

### **Step 4: Access Your Services**
- **Staging Web**: http://localhost:8080
- **Staging Grafana**: http://localhost:3000 (admin/admin)
- **Production Web**: http://localhost:8081
- **Production Grafana**: http://localhost:3001 (admin/admin)

## 🖥️ **Option 2: Vagrant (More Realistic - 10 minutes)**

### **Step 1: Install Vagrant**
```bash
# Ubuntu/Debian
sudo apt install vagrant virtualbox

# macOS
brew install vagrant virtualbox

# Windows
# Download from https://www.vagrantup.com/downloads
```

### **Step 2: Setup Environment**
```bash
# Make scripts executable
chmod +x scripts/setup-vagrant-hosts.sh

# Run the setup
./scripts/setup-vagrant-hosts.sh
```

### **Step 3: Deploy**
```bash
# Deploy to staging
./scripts/deploy.sh staging

# Deploy to production
./scripts/deploy.sh production
```

## ☁️ **Option 3: Cloud (Production Ready - 15 minutes)**

### **AWS Setup**
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS
aws configure

# Create instances (see docs/host-setup-guide.md for full details)
aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --count 1 \
    --instance-type t2.micro \
    --key-name your-key-pair \
    --security-groups ansible-dev
```

### **Update Inventory**
Edit `inventories/staging/hosts.yml` with your cloud IPs:
```yaml
web-staging-01:
  ansible_host: YOUR_AWS_IP
  ansible_user: ubuntu
  ansible_ssh_private_key_file: ~/.ssh/your-key.pem
```

## 🔧 **What You Get**

### **Infrastructure**
- **Multi-environment setup** (staging + production)
- **Load-balanced web servers**
- **Monitoring stack** (Prometheus + Grafana)
- **Security hardening** (firewall, SSL, fail2ban)

### **CI/CD Pipeline**
- **Automated testing** on every commit
- **Security scanning** with Trivy
- **Multi-stage deployments**
- **Health checks** and rollbacks

### **Monitoring**
- **System metrics** (CPU, memory, disk)
- **Application metrics** (Nginx performance)
- **Security events** (failed logins, blocks)
- **Custom dashboards**

## 🎯 **Next Steps**

### **1. Customize Your Application**
```bash
# Edit the web application
nano roles/webserver/templates/index.html.j2

# Update configuration
nano group_vars/all.yml
```

### **2. Add More Services**
```bash
# Create a new role
ansible-galaxy init roles/database

# Add to playbooks
nano playbooks/deploy-staging.yml
```

### **3. Set Up GitHub Actions**
1. Push your code to GitHub
2. Add repository secrets:
   - `STAGING_SSH_KEY`
   - `PRODUCTION_SSH_KEY`
   - `STAGING_HOST`
   - `PRODUCTION_HOST`
3. Watch the CI/CD pipeline run!

### **4. Monitor Your Infrastructure**
- Access Grafana: http://localhost:3000
- View system metrics
- Set up alerts
- Create custom dashboards

## 🚨 **Troubleshooting**

### **Common Issues**

**SSH Connection Failed**
```bash
# Test connectivity
ansible all -i inventories/staging/hosts.yml -m ping

# Check SSH keys
ls -la ~/.ssh/
```

**Docker Containers Not Starting**
```bash
# Check Docker status
docker ps -a
docker-compose logs

# Restart containers
docker-compose down && docker-compose up -d
```

**Ansible Playbook Fails**
```bash
# Run with verbose output
ansible-playbook -i inventories/staging/hosts.yml playbooks/deploy-staging.yml -vvv

# Check syntax
ansible-playbook --syntax-check playbooks/deploy-staging.yml
```

### **Get Help**
```bash
# View logs
docker-compose logs -f
vagrant ssh web-staging -c "sudo journalctl -f"

# Check service status
ansible all -i inventories/staging/hosts.yml -m shell -a "systemctl status nginx"
```

## 📚 **Learning Path**

1. **Start with Docker** - Understand the basics
2. **Move to Vagrant** - Learn VM management
3. **Deploy to Cloud** - Production experience
4. **Customize** - Add your own services
5. **Scale** - Add more environments

## 🎉 **Congratulations!**

You now have a production-ready DevOps infrastructure with:
- ✅ Infrastructure as Code
- ✅ CI/CD Pipeline
- ✅ Monitoring & Observability
- ✅ Security Best Practices
- ✅ Multi-environment Support

**Ready to deploy your first application!** 🚀 