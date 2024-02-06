# SEE Academy

This repository contains the Terraform code for the SEE Academy labs.


## Prerequisites

Before you can apply the Terraform code, make sure you have the following prerequisites:

- Git: [Git Installation Guide](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- Terraform: [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Azure CLI: [Azure CLI Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Creating the Infrastructure

To apply the infrastructure for the SEE Academy project, follow these steps:

1. Clone the repository: `git clone https://github.com/your-username/see-academy.git`
2. Configure your Azure credentials: [Azure CLI Configuration Guide](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli)
3. Initialize the Terraform project: `terraform init`
4. Deploy the infrastructure: `terraform apply`

## Destroying the Infrastructure

To destroy the infrastructure created by Terraform, follow these steps:

1. Open a terminal or command prompt.
2. Navigate to the project directory: `cd see-academy`
3. Run the Terraform destroy command: `terraform destroy --auto-approve`

## License

This project is licensed under the [MIT License](LICENSE).

