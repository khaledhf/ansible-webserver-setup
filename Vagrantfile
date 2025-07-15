# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Use Ubuntu 20.04 as base box
  config.vm.box = "ubuntu/focal64"
  config.vm.box_version = "20211026.0.0"
  
  # Disable automatic box updates
  config.vm.box_download_insecure = true
  
  # Configure the VM provider
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
    vb.name = "ansible-dev"
  end
  
  # Staging Environment
  config.vm.define "web-staging" do |web_staging|
    web_staging.vm.hostname = "web-staging-01"
    web_staging.vm.network "private_network", ip: "192.168.2.10"
    web_staging.vm.network "forwarded_port", guest: 80, host: 8080
    web_staging.vm.network "forwarded_port", guest: 443, host: 8443
    
    web_staging.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
      vb.name = "web-staging-01"
    end
    
    # Provision the VM
    web_staging.vm.provision "shell", inline: <<-SHELL
      # Update system
      apt-get update
      apt-get install -y openssh-server sudo python3 curl
      
      # Create ubuntu user
      useradd -m -s /bin/bash ubuntu
      echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
      
      # Setup SSH
      mkdir -p /home/ubuntu/.ssh
      chown -R ubuntu:ubuntu /home/ubuntu/.ssh
      chmod 700 /home/ubuntu/.ssh
      
      # Enable SSH service
      systemctl enable ssh
      systemctl start ssh
    SHELL
  end
  
  config.vm.define "monitor-staging" do |monitor_staging|
    monitor_staging.vm.hostname = "monitor-staging-01"
    monitor_staging.vm.network "private_network", ip: "192.168.2.20"
    monitor_staging.vm.network "forwarded_port", guest: 9090, host: 9090
    monitor_staging.vm.network "forwarded_port", guest: 3000, host: 3000
    
    monitor_staging.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
      vb.name = "monitor-staging-01"
    end
    
    monitor_staging.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y openssh-server sudo python3 curl
      
      useradd -m -s /bin/bash ubuntu
      echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
      
      mkdir -p /home/ubuntu/.ssh
      chown -R ubuntu:ubuntu /home/ubuntu/.ssh
      chmod 700 /home/ubuntu/.ssh
      
      systemctl enable ssh
      systemctl start ssh
    SHELL
  end
  
  # Production Environment
  config.vm.define "web-prod-01" do |web_prod_01|
    web_prod_01.vm.hostname = "web-prod-01"
    web_prod_01.vm.network "private_network", ip: "192.168.1.10"
    web_prod_01.vm.network "forwarded_port", guest: 80, host: 8081
    web_prod_01.vm.network "forwarded_port", guest: 443, host: 8444
    
    web_prod_01.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
      vb.name = "web-prod-01"
    end
    
    web_prod_01.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y openssh-server sudo python3 curl
      
      useradd -m -s /bin/bash ubuntu
      echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
      
      mkdir -p /home/ubuntu/.ssh
      chown -R ubuntu:ubuntu /home/ubuntu/.ssh
      chmod 700 /home/ubuntu/.ssh
      
      systemctl enable ssh
      systemctl start ssh
    SHELL
  end
  
  config.vm.define "web-prod-02" do |web_prod_02|
    web_prod_02.vm.hostname = "web-prod-02"
    web_prod_02.vm.network "private_network", ip: "192.168.1.11"
    web_prod_02.vm.network "forwarded_port", guest: 80, host: 8082
    web_prod_02.vm.network "forwarded_port", guest: 443, host: 8445
    
    web_prod_02.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
      vb.name = "web-prod-02"
    end
    
    web_prod_02.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y openssh-server sudo python3 curl
      
      useradd -m -s /bin/bash ubuntu
      echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
      
      mkdir -p /home/ubuntu/.ssh
      chown -R ubuntu:ubuntu /home/ubuntu/.ssh
      chmod 700 /home/ubuntu/.ssh
      
      systemctl enable ssh
      systemctl start ssh
    SHELL
  end
  
  config.vm.define "monitor-prod" do |monitor_prod|
    monitor_prod.vm.hostname = "monitor-prod-01"
    monitor_prod.vm.network "private_network", ip: "192.168.1.20"
    monitor_prod.vm.network "forwarded_port", guest: 9090, host: 9091
    monitor_prod.vm.network "forwarded_port", guest: 3000, host: 3001
    
    monitor_prod.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
      vb.name = "monitor-prod-01"
    end
    
    monitor_prod.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y openssh-server sudo python3 curl
      
      useradd -m -s /bin/bash ubuntu
      echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
      
      mkdir -p /home/ubuntu/.ssh
      chown -R ubuntu:ubuntu /home/ubuntu/.ssh
      chmod 700 /home/ubuntu/.ssh
      
      systemctl enable ssh
      systemctl start ssh
    SHELL
  end
end 