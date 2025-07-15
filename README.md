# 🚀 Enhanced DevOps Infrastructure

A comprehensive DevOps setup with Ansible automation, CI/CD pipelines, and monitoring solutions.

## 📋 Features

### 🔧 Infrastructure as Code
- **Multi-environment support** (staging, production)
- **Security-first approach** with UFW, Fail2ban, and SSL
- **Performance optimized** Nginx configuration
- **Comprehensive monitoring** with Prometheus and Grafana

### 🔄 CI/CD Pipeline
- **Automated testing** with linting and security scans
- **Multi-stage deployments** (staging → production)
- **Health checks** and rollback capabilities
- **Security scanning** with Trivy and Bandit

### 📊 Monitoring & Observability
- **Prometheus** for metrics collection
- **Grafana** for visualization and dashboards
- **Node Exporter** for system metrics
- **Health endpoints** for service monitoring

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │  GitHub Actions │    │   Production    │
│                 │───▶│   CI/CD Pipeline│───▶│   Environment   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │    Staging      │
                       │   Environment   │
                       └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Monitoring    │
                       │  (Prometheus +  │
                       │    Grafana)     │
                       └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Ubuntu 20.04+ servers
- SSH key-based authentication
- Python 3.8+
- Ansible 2.12+

### 1. Clone and Setup
```bash
git clone <your-repo>
cd ansible-webserver-setup
```

### 2. Configure Inventory
Edit the inventory files in `inventories/` with your server details:

```yaml
# inventories/staging/hosts.yml
all:
  children:
    webservers:
      hosts:
        web-staging-01:
          ansible_host: YOUR_STAGING_IP
          ansible_user: ubuntu
```

### 3. Deploy to Staging
```bash
ansible-playbook -i inventories/staging/hosts.yml playbooks/deploy-staging.yml
```

### 4. Deploy to Production
```bash
ansible-playbook -i inventories/production/hosts.yml playbooks/deploy-production.yml
```

## 🔧 Configuration

### Environment Variables
Set these in your GitHub repository secrets:

- `STAGING_SSH_KEY`: SSH private key for staging servers
- `PRODUCTION_SSH_KEY`: SSH private key for production servers
- `STAGING_HOST`: Staging server IP/hostname
- `PRODUCTION_HOST`: Production server IP/hostname

### Customization
- Modify `group_vars/all.yml` for global settings
- Update role variables in inventory files
- Customize monitoring dashboards in `roles/monitoring/templates/`

## 📊 Monitoring

### Access Points
- **Grafana**: http://your-server:3000 (admin/admin)
- **Prometheus**: http://your-server:9090
- **Health Check**: http://your-server/health

### Key Metrics
- System resources (CPU, Memory, Disk)
- Nginx performance and errors
- Security events (Fail2ban)
- Application health status

## 🔒 Security Features

- **Firewall**: UFW with minimal open ports
- **Intrusion Prevention**: Fail2ban with custom rules
- **SSL/TLS**: Automatic certificate generation
- **Security Headers**: XSS protection, HSTS, etc.
- **Rate Limiting**: Nginx-based request throttling

## 🛠️ Development

### Local Testing
```bash
# Test playbook syntax
ansible-playbook --syntax-check playbooks/deploy-staging.yml

# Run with dry-run
ansible-playbook --check playbooks/deploy-staging.yml

# Test specific tags
ansible-playbook -i inventories/staging/hosts.yml playbooks/deploy-staging.yml --tags "nginx,security"
```

### Adding New Roles
1. Create role structure: `roles/new-role/{tasks,handlers,templates,defaults}`
2. Add role to playbooks
3. Update CI/CD pipeline if needed

## 📈 CI/CD Pipeline

### Workflow Triggers
- **Push to `develop`**: Deploy to staging
- **Push to `main`**: Deploy to production
- **Pull Request**: Run tests and security scans
- **Manual**: Trigger deployments via GitHub Actions

### Pipeline Stages
1. **Lint & Test**: Ansible syntax, linting, Molecule tests
2. **Security Scan**: Trivy vulnerability scanning
3. **Deploy Staging**: Automated staging deployment
4. **Deploy Production**: Manual approval required
5. **Health Checks**: Post-deployment validation

## 🚨 Troubleshooting

### Common Issues
1. **SSH Connection Failed**: Check SSH keys and firewall rules
2. **Nginx Won't Start**: Verify configuration syntax
3. **Monitoring Not Working**: Check Prometheus/Grafana services
4. **SSL Issues**: Verify certificate paths and permissions

### Debug Commands
```bash
# Check Ansible connectivity
ansible all -i inventories/staging/hosts.yml -m ping

# View Nginx logs
sudo tail -f /var/log/nginx/error.log

# Check service status
sudo systemctl status nginx prometheus grafana-server

# Test monitoring endpoints
curl http://localhost:9090/-/healthy
curl http://localhost:3000/api/health
```

## 📚 Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details. 