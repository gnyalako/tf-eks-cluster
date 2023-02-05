# Initialisation

This layer is used to create VPC and KMS resources.

# Pre-requisite

- A valid AWS profile ready to use via CLI.
- Terraform version > 1.1.5 (version 1.3.7 suggested)

### Create

Update the `terraform.tfvars` file to include the required `aws_account_id`. Optional variables are: `environment` and `region`.

- update terraform.tfvars with your `aws_account_id`.

```bash
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
```

### Destroy

```bash
$ terraform destroy
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_account\_id | (Required) The AWS Account ID. | string | n/a | yes |
| region | (Optional) Region where resources will be created. | string | `us-east-1` | no |
| environment | (Optional) The name of the environment, e.g. Production, Development, etc. | string | `Development` | no |

## Inputs for VPC

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| vpc\_cidr | (Optional) CIDR range for the VPC. | string | `10.0.0.0/16` | no |
| vpc\_name | (Optional) Name of the VPC. If `null` it will be `${var.cluster_name}-vpc`. | string | `null` | no |

## Inputs for EKS

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | (Optional) Name of the EKS Cluster. | string | `devops-cluster` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc\_id | The ID of the VPC. |
| vpc_cidr | The CIDR block of the VPC. |
| private\_subnets | List of IDs of private subnets. |
| public\_subnets | List of IDs of public subnets. |
| intra\_subnets | List of IDs of intra subnets. |
| eks\_kms\_key\_arn | The ARN of the EKS KMS Key. |
