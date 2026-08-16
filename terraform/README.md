# Terraform Setup

## Step 1: Remote Backend Setup in Bootstrap Folder

### Tasks

1. Create the S3 bucket using `s3.tf`.
2. Create `outputs.tf` to generate the S3 backend configuration.
3. Generate the `backend.hcl` file from the Terraform output : `terraform output -raw backend_hcl > ../backend.hcl`
4. Use the generated `backend.hcl` in the application folder to connect to the same S3 backend and state.

## Step 2: Create application folder to create project aws infra structure

### Tasks
1. To initialize the application with root `backend.hcl` file use : `terraform init -backend-config=../backend.hcl`
2. To create remote backend for application folder use empty backend s3 block :
```bash
terraform {
  backend "s3" {}
}
```
## Step 3: Steps for provisioning aws environment to create vpc , eks and their dependencies

### Flow
1. Create `vpc.tf` and create interpolation using  `variables.tf` , `locals.tf` and `terraform.tfvars`
2. `terraform.tf` file enables declare which providers to use 
3. Create eks cluster configuration in `eks.tf`
4. Eks cluster provides required values to other .tf files like :
   - Provides cluster endpoints and cluster tokens to `providers.tf`
   - Provides cluster name and other data to `pod_identity-eso.tf`
5. Some resources are only useful if eks cluster exits :
   - `volume-storage-class.tf` is only useful if worker nodes are exits
   - `argocd.tf` is only useful if eks cluster production environment exits like pod.yml and etc
