# DevOps Monitoring

## 1. Terraform

First authenticate to google-cloud since we are using it for this lab.

```bash
brew install gcloud # or other pkg manager
gcloud init # Connect gcloud sdk with your acc
gcloud auth application-default login # Create local auth credentials
```

> Credentials are stored to ~/.config/gcloud/application_default_credentials.json

After setting up credentials we can start setting up our infrastructure with terraform.

```bash
cd terraform
terraform init
vim terraform.tfvars
```

> You can help determining which values to use with the following commands:
>
> ```bash
> gcloud compute zones list
> gcloud compute regions list
> gcloud compute images list
> gcloud compute machine-types list --zones=<ZONE>
> ```

After setting up variables we provision infrastructure

```bash
terraform plan
terraform apply
```

## 2. Ansible

First prepare vault where we will store secrets. We extract need to transfer tree values from terraform output:

- lb_ip
- masters_ip
- workers_ip

Change vars to your own.

```bash
$ cd ansible
$ echo "vault_password" > vault_secret
$ ansible-vault create --vault-pass-file vault_secret vault.yml
---
ansible_user: "<ci_username>"
ansible_ssh_private_key_file: "<ci_private_key>"
acme_email: "<acme_email>" # For cert manager's acme issuer
rke2_additional_sans: ["lb_ip"]
cloudflare_token: "<cloudflare_token>" # For cert manager dns01 challenge
bitwarden_access_token: "<bitwarden_access_token>" # For bitwarden external secrets
bitwarden_organization_id: "<bitwarden_organization_id>" # For bitwarden external secrets
bitwarden_project_id: "<bitwarden_project_id>" # For bitwarden external secrets
```

Then edit the hosts in the ansible/inventories/inventory.yml file to match your terraform setup.

```bash
$ vim ansible/inventories/inventory.yml
---
all:
  children:
    k8s_clsuter:
      children:
        masters:
          hosts:
            master-0:
              ansible_host: <MASTER0_IP>
            ...
        workers:
          hosts:
            worker-0:
              ansible_host: <WORKER0_IP>
            ...
```

Then we start ansible playbook to provision our cluster

```bash
$ ansible-playbook ./deploy.yml
```

## 3. ArgoCD

After ansible playbook is done, argocd automatically provisions itself, and all apps defined in argocd directory.
