# Ansible Configurations

## Step 1 :  Install Python Dependencies Locally
```
sudo apt-get update && sudo apt-get install -y python3-boto3 python3-botocore
```

## Step 2 : Download the Ansible AWS Collection
```
ansible-galaxy collection install amazon.aws --force
```

## Step 3 : Create the Config File (ansible.cfg)
```
vim ansible.cfg
```

### Paste this Content :
```
[inventory]
enable_plugins = amazon.aws.aws_ec2, host_list, script, auto, yaml, ini
```

## Step 4 : Write the Dynamic Inventory Schema (inventory.aws_ec2.yml)
```
plugin: amazon.aws.aws_ec2
boto_profile: default

regions:
  - us-east-1

filters:
  tag:Environment: production
  tag:Role: application

keyed_groups:
  - key: ec2_tags.Role
    prefix: role
  - key: ec2_tags.Environment
    prefix: env

compose:
  ansible_host: public_ip_address
```

## Command to execute inventory.ini for ping to ec2 instance
```
ansible -i inventory.aws_ec2.yml all -m ping -u ubuntu --private-key Ansible-Key.pem --ask-vault-pass
```

## Command to execute .yml file 
```
ansible-playbook   -i inventory.aws_ec2.yml 3_clone_repo.yml   -u ubuntu   --private-key Ansible-Key.pem   --ask-vault-pass
```

## Note :
```
Always use these tags to configure instance using this ansible infrastructure
Environment = "production"
Role = "application"
```