<!-- BEGIN_TF_DOCS -->
<p align="center">                                                                                                                                            
                                                                                
  <img src="https://github.com/StratusGrid/terraform-readme-template/blob/main/header/stratusgrid-logo-smaller.jpg?raw=true" />
  <p align="center">
    <a href="https://stratusgrid.com/book-a-consultation">Contact Us Test</a>
    <a href="https://stratusgrid.com/cloud-cost-optimization-dashboard">Stratusphere FinOps</a>
    <a href="https://stratusgrid.com">StratusGrid Home</a>
    <a href="https://stratusgrid.com/blog">Blog</a>
  </p>
</p>

# terraform-aws-firehose-datadog-metrics-streaming

GitHub: [StratusGrid/terraform-aws-datadog-metrics-streaming](https://github.com/StratusGrid/terraform-aws-datadog-metrics-streaming)

This module creates a CloudWatch metrics stream and Firehose directed to a DataDog integration metrics ingest URL. For this reason, it disables datadog integrations which would be duplicated by a CloudWatch stream by default. The typical approach is to create one integration per account and one metrics stream per region (see example below).

This is meant to be used with our module which creates the DataDog integration, which can be found here: [datadog-integration-streaming](https://registry.terraform.io/modules/StratusGrid/datadog-integration-streaming/aws/latest)

## Example

Multi-region Example utilizing both the integration module to make the account level integration in DataDog and the metrics streaming module to create the Firehose and metrics stream in each region.
```hcl
# Standard Variables and Locals
variable "env_name" {
  description = "Environment name string to be used for decisions and name generation"
  type        = string
}

variable "name_prefix" {
  description = "String to use as prefix on object names"
  type        = string
}

variable "name_suffix" {
  description = "String to append to object names. This is optional, so start with dash if using."
  type        = string
  default     = ""
}

variable "source_repo" {
  description = "name of repo which holds this code"
  type        = string
}

locals {
  name_suffix = "${var.name_suffix}-${var.env_name}"
}

locals {
  common_tags = {
    Environment = var.env_name
    #   Application = var.application_name
    Developer   = "StratusGrid"
    Provisioner = "Terraform"
    SourceRepo  = var.source_repo
  }
}

# Solution Specific Variables and Locals
variable "datadog_api_secret_arn" {
  description = "The ARN of the secret which has the DataDog api key, app key, and api url. Value should be in json format with keys datadog_api_key, datadog_app_key, datadog_api_url, and datadog_firehose_delivery_stream_url "
  type        = string
}

locals {
  datadog_host_tags = [
    "environment:${var.env_name}",
    "account-name:${data.aws_iam_account_alias.current.account_alias}"
  ]
}

# Providers
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  default_tags {
    tags = merge(
      local.common_tags
    )
  }
}

provider "aws" {
  region = "us-west-2"
  alias  = "us-west-2"
  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  region = "eu-west-2"
  alias  = "eu-west-2"
  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  region = "ca-central-1"
  alias  = "ca-central-1"
  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  region = "sa-east-1"
  alias  = "sa-east-1"
  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  region = "eu-central-1"
  alias  = "eu-central-1"
  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  region = "ap-southeast-1"
  alias  = "ap-southeast-1"
  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  region = "ap-southeast-2"
  alias  = "ap-southeast-2"
  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  region = "ap-northeast-1"
  alias  = "ap-northeast-1"
  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  region = "ap-northeast-2"
  alias  = "ap-northeast-2"
  default_tags {
    tags = local.common_tags
  }
}

# Data Calls
data "aws_caller_identity" "current" {}

data "aws_iam_account_alias" "current" {}

data "aws_secretsmanager_secret_version" "datadog_secret" {
  secret_id = var.datadog_api_secret_arn
}

#Account level DataDog integration
module "datadog_integration" {
  # source                               = "github.com/StratusGrid/terraform-aws-datadog-integration-streaming"
  source            = "StratusGrid/datadog-integration-streaming/aws"
  version           = "1.0.1"
  name              = "${var.name_prefix}-integration-${data.aws_caller_identity.current.account_id}${local.name_suffix}"
  input_tags        = local.common_tags
  datadog_api_key   = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_app_key   = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_app_key"]
  datadog_api_url   = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_url"]
  datadog_host_tags = local.datadog_host_tags
  providers = {
    aws = aws.us-east-1
  }
}

#Per region level DataDog integration metrics streams with firehose
module "datadog_integration_us_east_1" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.1"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-us-east-1${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.us-east-1
  }
}

module "datadog_integration_us_west_2" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.1"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-us-west-2${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.us-west-2
  }
}

module "datadog_integration_ca_central_1" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.1"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-ca-central-1${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.ca-central-1
  }
}

module "datadog_integration_sa-east-1" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.1"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-sa-east-1${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.sa-east-1
  }
}

module "datadog_integration_eu_west_2" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.1"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-eu-west-2${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.eu-west-2
  }
}

module "datadog_integration_eu_central_1" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.1"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-eu-central-1${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.eu-central-1
  }
}

module "datadog_integration_ap_southeast_1" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.1"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-ap-southeast-1${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.ap-southeast-1
  }
}

module "datadog_integration_ap_southeast_2" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.1"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-ap-southeast-2${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.ap-southeast-2
  }
}

module "datadog_integration_ap_northeast_1" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.1"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-ap-northeast-1${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.ap-northeast-1
  }
}

module "datadog_integration_ap_northeast_2" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.1"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-ap-northeast-2${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.ap-northeast-2
  }
}
```
---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_stream.datadog_metric_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_stream) | resource |
| [aws_iam_role.firehose_datadog_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.metric_stream_to_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.metric_stream_s3_failed_upload_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.metric_stream_to_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kinesis_firehose_delivery_stream.datadog_firehose_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_s3_bucket.datadog_aws_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.failed_data_bucket_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.failed_data_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.failed_data_bucket_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cw_namespace_exclude_filters"></a> [cw\_namespace\_exclude\_filters](#input\_cw\_namespace\_exclude\_filters) | Pairings of Namespaces and Metrics which should be excluded from the CloudWatch Metrics Stream. | <pre>list(object({<br>    metric_names = list(string),<br>    namespace    = string<br>  }))</pre> | `[]` | no |
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | Datadog API Key | `string` | n/a | yes |
| <a name="input_datadog_firehose_delivery_stream_url"></a> [datadog\_firehose\_delivery\_stream\_url](#input\_datadog\_firehose\_delivery\_stream\_url) | Datadog URL for the Firehose Delivery stream to send metrics. Marked sensitive because the some endpoints requires a key in the url. | `string` | n/a | yes |
| <a name="input_input_tags"></a> [input\_tags](#input\_input\_tags) | Map of tags to apply to resources | `map(string)` | <pre>{<br>  "Developer": "StratusGrid",<br>  "Provisioner": "Terraform"<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | name to prepend to all resource names within module. NOTE: For this DataDog firehose integration, it is recommended to use a format that includes the AWS Account number and region since it is account and region specific. | `string` | n/a | yes |

## Outputs

No outputs.

---

Note, manual changes to the README will be overwritten when the documentation is updated. To update the documentation, run `terraform-docs -c .config/.terraform-docs.yml`
<!-- END_TF_DOCS -->