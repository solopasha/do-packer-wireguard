# Packer Terraform Ansible Wireguard DigitalOcean

- A DigitalOcean [API key](https://www.digitalocean.com/docs/api/create-personal-access-token/)
- Packer [installed](https://www.packer.io/intro/getting-started/install.html)
- Terraform [installed](https://learn.hashicorp.com/terraform/getting-started/install.html)
- Ansible [installed](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

```bash
sudo pacman -Syu packer terraform ansible
```

Export API key ``` export TF_VAR_do_api_token="" ``` or add to `packer/template.json`, `terraform/terraform.tfvars`.

Validate template files.

```bash
cd packer
packer validate template.json
```

Build image.

```bash
packer build template.json
```

Initialize Terraform.

```bash
terraform init
```

Preview.

```bash
terraform plan
```

Deploy the image to a Droplets.

```bash
terraform apply -auto-approve
```

wireguard configuration(s) will be in *wg_download_path*(defined in *ansible/roles/wireguard/defaults/main.yml*).

Destroy/del Droplets.

```bash
terraform destroy -auto-approve
```
