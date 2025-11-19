# Nginx Ansible

This Ansible playbook automates the installation and configuration of Nginx + Let’s Encrypt (Certbot) on a Linux host.
It sets up a production-ready HTTPS web server using the ACME HTTP-01 Webroot challenge, ensuring secure TLS certificates and auto-renewal.

The playbook is designed to work with Debian-based distributions (Ubuntu 24.04).

## Features
	•	Automated Nginx installation and configuration
	•	Automatic creation of webroot for ACME challenges
	•	Certbot installation and certificate issuance using the --webroot method
	•	Automatic renewal of TLS certificates
	•	Optional reverse proxy configuration using templates with `proxy-watcher`
	•	Fully customizable domain, email, and webroot paths
	•	Infrastructure-as-Code workflow using Ansible roles

## Requirements

### Local Machine (Ansible Control Node)
- Ansible 2.9 or later
- Python 3.x
- SSH access to the target server
- A valid domain name pointing to the server

### Target Server
The playbook installs the following packages automatically:
- nginx
- certbot
- curl

Ensure:
- The server has internet access
- Port 80/tcp is publicly accessible (HTTP-01 requirement)


## Installation
1.	Clone or download this repository:

```bash
git clone https://github.com/HOchacha/nginx-ansible.git
cd nginx-ansible
```

2.	Edit the inventory file to specify your Nginx host. Example:

```bash
inventory/hosts.ini
inventory/test-boan.kloud.zone.ini
```

3.	Update variables inside group_vars/nginx.yml:

```bash
domain_name: "example.com"
letsencrypt_email: "admin@example.com"
webroot_path: "/var/www/html"
```

4.	Run the playbook to install and configure Nginx & Certbot:

```bash
ansible-playbook -i hosts.ini site.yml --ask-pass
```

## Usage

### Initial Nginx & HTTPS Setup
Running the main playbook will:
- Install Nginx
- Create webroot and ACME challenge directories
- Deploy Nginx configuration (template-driven)
- Install Certbot
- Issue a TLS certificate via HTTP-01 challenge
- Reload Nginx
- Enable automatic certificate renewals

After installation, the TLS certificate will be stored at:

```bash
/etc/letsencrypt/live/<domain_name>/
```

# Certificate Renewal

Certbot’s systemd timer automatically renews certificates before expiration.

Check renewal timer:
```
systemctl status certbot.timer
```
Manual renewal test:
```
sudo certbot renew --dry-run
```


# Directory Structure (Example)
```
nginx-ansible/
├─ inventory/
│  └─ hosts.ini
├─ group_vars/
│  └─ nginx.yml
├─ roles/
│  └─ nginx/
│     ├─ tasks/
│     │  ├─ install.yml
│     │  ├─ webroot.yml
│     │  ├─ certbot.yml
│     │  └─ service.yml
│     ├─ templates/
│     │  └─ nginx.conf.j2
├─ site.yml
└─ README.md
```

# After Installation

Your server will have:

1. Nginx running with HTTPS enabled

Configuration file typically located at:
```
/etc/nginx/sites-available/default
```
2. Webroot for serving ACME challenge
```
/var/www/html/.well-known/acme-challenge/
```
3. Valid TLS Certificates
```
fullchain.pem
privkey.pem
chain.pem
```
4. Auto-renewal enabled
```
certbot.timer → active
```

# Removing or Reinstalling

You can safely remove:
	•	/etc/nginx/sites-available/default (custom configs)
	•	/etc/letsencrypt/ (certificates)
	•	/var/www/html/* (webroot)

If you want, I can also generate a cleanup.yml playbook.

### Notes
	•	Ensure your DNS A record points to your server before issuing certificates
	•	Port 80 must remain open for renewal (HTTP-01)
	•	Supports both single-domain and multi-domain certificates

