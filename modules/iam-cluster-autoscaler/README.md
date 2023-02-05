# EKS IAM cluster autoscaler module

Configure IAM role and related policies to use the EKS cluster autoscaler

## Usage
```hcl
module "cluster_autoscaler" {
  source = "./modules/iam-cluster-autoscaler"

  cluster_name         = module.eks.cluster_name
  issuer_url           = module.eks.cluster_oidc_issuer_url
  kubernetes_namespace = "kube-system"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.20 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.8 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of EKS cluster (must match) | `string` | n/a | yes |
| <a name="input_issuer_url"></a> [issuer\_url](#input\_issuer\_url) | OIDC issuer URL (include prefix) | `string` | n/a | yes |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | Namespace to operate in (service accounts and pods must be in the same namespace) | `string` | `"kube-system"` | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Name of service account to create | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add to supported resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_cluster_autoscaler_arn"></a> [iam\_role\_cluster\_autoscaler\_arn](#output\_iam\_role\_cluster\_autoscaler\_arn) | IAM role ARN |
| <a name="output_iam_role_cluster_autoscaler_name"></a> [iam\_role\_cluster\_autoscaler\_name](#output\_iam\_role\_cluster\_autoscaler\_name) | IAM role name |
