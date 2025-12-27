# Homelab InfluxDB

Ansible project for deploying [InfluxDB](https://www.influxdata.com/products/influxdb/) via Docker Compose on a single host.

**Target host:** `influxdb.local.iamrobertyoung.co.uk`

## Project Structure

```
.
├── ansible.cfg                 # Ansible configuration
├── inventories/
│   ├── hosts.yml               # Inventory with influxdb group
│   └── group_vars/             # Group variables
├── host_vars/                  # Host-specific variables
├── roles/
│   └── influxdb/               # Custom InfluxDB role
├── .roles/                     # External roles (gitignored)
├── playbooks/
│   └── site.yml                # Main playbook
├── files/                      # Static files
├── templates/                  # Jinja2 templates
├── scripts/                    # Utility scripts
└── requirements.yml            # External role dependencies
```

## Prerequisites

- Ansible installed (see `mise.toml` for version)
- SSH access to the target host
- AWS credentials via aws-vault for SSM parameter access (region: eu-west-2)

## Setup

Install external role dependencies:

```bash
aws-vault exec iamrobertyoung:home-assistant-production:p -- ansible-galaxy install -r requirements.yml -p .roles
```

## Usage

All commands require AWS credentials via aws-vault for SSM parameter lookups.

### Test connectivity

```bash
aws-vault exec iamrobertyoung:home-assistant-production:p -- ansible influxdb -m ping
```

### Run full playbook

```bash
aws-vault exec iamrobertyoung:home-assistant-production:p -- ansible-playbook playbooks/site.yml
```

### Run specific role

```bash
aws-vault exec iamrobertyoung:home-assistant-production:p -- ansible-playbook playbooks/site.yml --tags influxdb
```

## Roles

The playbook applies these roles in order:

| Role | Source | Description |
|------|--------|-------------|
| `configure-system` | External | Base system configuration |
| `shell` | External | Shell setup (noxious, root users) |
| `docker` | External | Docker installation |
| `telegraf` | External | Metrics collection to InfluxDB |
| `step-ca-client` | External | TLS certificates from Step CA |
| `syslog` | External | Syslog configuration |
| `wazuh-agent` | External | Wazuh security agent |
| `influxdb` | Custom | InfluxDB deployment |

## Available Tags

Run specific parts of the playbook:

- `configure-system`
- `shell`
- `docker`
- `telegraf`
- `step-ca-client`
- `syslog`
- `wazuh-agent`
- `influxdb`

## Secrets

Secrets are stored in AWS SSM Parameter Store (eu-west-2) and retrieved via `lookup('aws_ssm', ...)`.

## Adding Roles

Create a new custom role:

```bash
ansible-galaxy init roles/role_name
```

Add external roles to `requirements.yml` and install:

```bash
aws-vault exec iamrobertyoung:home-assistant-production:p -- ansible-galaxy install -r requirements.yml -p .roles
```
