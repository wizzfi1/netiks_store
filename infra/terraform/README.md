# Netiks Store - Terraform Infrastructure

Terraform code that describes the Azure infrastructure backing the Netiks Store deployment.
All resources were originally created manually during the lab weeks; this code brings them
under version-controlled Infrastructure as Code management.

## Module Structure

```
infra/terraform/
├── main.tf                   # Root module - calls all child modules
├── variables.tf              # All input variable declarations
├── outputs.tf                # Key outputs (public IP, ACR login server)
├── terraform.tfvars.example  # Copy this to terraform.tfvars and fill in secrets
├── import.sh                 # One-time script to adopt existing resources
└── modules/
    ├── networking/           # VNet, subnet, NSG rules, public IP
    ├── compute/              # NIC, Linux VM, managed identity
    └── registry/             # Azure Container Registry, AcrPull role assignment
```

### Why three modules?

Each module owns a distinct infrastructure concern with a clear boundary:

- **networking** - everything that controls how traffic reaches the VM. The NSG rules
  here directly correspond to the application's access model: port 22 for SSH ops,
  port 80 for production (Nginx), port 443 for HTTPS, port 8080 for staging (Nginx).
  Keeping this separate means firewall changes never touch compute or registry code.

- **compute** - the VM and its NIC. The VM is configured with a system-assigned managed
  identity so the deploy pipeline can authenticate with ACR using short-lived tokens
  from the Azure Instance Metadata Service rather than long-lived admin credentials.
  The NIC takes its subnet and public IP IDs as inputs from the networking module.

- **registry** - the Azure Container Registry and the AcrPull role assignment that
  grants the VM's managed identity pull access. Keeping the role assignment in the
  registry module keeps the permission co-located with the resource it controls.

## Variables

| Variable | Default | Description |
|---|---|---|
| `subscription_id` | - | Azure subscription ID (required) |
| `admin_ssh_public_key` | - | SSH public key for azureuser (required, sensitive) |
| `resource_group_name` | `netiks-rg` | Azure resource group |
| `location` | `southafricanorth` | Azure region |
| `vm_name` | `netiks-vm` | VM name |
| `vm_size` | `Standard_B2as_v2` | VM SKU |
| `registry_name` | `wisdomnetiks` | ACR name (globally unique) |
| `registry_sku` | `Basic` | ACR pricing tier |

See `variables.tf` for the full list including networking variables.

## Using This Code

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6.0
- Azure CLI installed and authenticated (`az login`)

### First-time setup (existing environment)

The existing infrastructure was created manually, so Terraform has no state for it yet.
Use the import script to adopt the existing resources before running plan or apply.

```bash
cd infra/terraform

# 1. Copy and fill in the secrets file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars - add subscription_id and admin_ssh_public_key

# 2. Initialise Terraform (downloads the azurerm provider)
terraform init

# 3. Import existing resources into state
bash import.sh

# 4. Verify - plan should show no changes (or only minor drift)
terraform plan

# 5. Apply only if the plan looks correct
terraform apply
```

### Standing up a new environment from scratch

To create an entirely new environment (no existing resources to import):

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with new values (different resource_group_name, vm_name, etc.)
terraform init
terraform plan
terraform apply
```

### Destroying an environment

```bash
terraform destroy
```

Never run `terraform destroy` against the production environment.

## What Is Not Yet Templated

The following parts of the setup exist but are not yet covered by this Terraform code.
They are honest gaps, not oversights - they would be the next additions given more time:

- **VM provisioning (cloud-init / Ansible)** - the VM is created by Terraform but the
  software installed on it (Docker, Docker Compose, Nginx, the deploy user, SSH keys,
  the staging clone at /home/deploy/netiks_store-staging) is still done manually after
  the VM starts. A cloud-init script or Ansible playbook would make this repeatable.

- **Nginx configuration** - the production and staging Nginx server blocks are configured
  by hand on the VM. These should be templated as part of the provisioning step above.

- **GitHub Actions secrets** - DEPLOY_HOST, DEPLOY_USER, DEPLOY_SSH_KEY, and the
  AZURE_* OIDC variables in the production and staging GitHub environments are set
  manually. The GitHub Terraform provider could manage these.

- **Azure OIDC federated credentials** - the app registration and federated identity
  credentials used by GitHub Actions to authenticate with Azure (set up in Week 4-5)
  are not yet in code. The azuread Terraform provider covers these resources.

- **DNS** - there is no custom domain configured yet. If one were added, the DNS record
  would belong in the networking module or a dedicated dns module.

- **ACR lifecycle policies** - no image retention rules are configured on the registry.
  Old SHA-tagged images accumulate indefinitely. A lifecycle policy would belong in the
  registry module.
