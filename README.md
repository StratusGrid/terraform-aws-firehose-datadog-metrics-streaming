<!-- BEGIN_TF_DOCS -->
# template-terraform-module-starter

GitHub: [StratusGrid/template-terraform-module-starter](https://github.com/StratusGrid/template-terraform-module-starter)

This Repo is meant to act as a template which can be used
when creating new modules.

<span style="color:red">**Notes:</span>
- Don't forget to change the module source repo tag in `tags.tf`!
- Please remove all of the unnecessary initial documentation from the `.terraform-docs.yml` file as they exist purely to make the module and not for continual publishing.
- Update the examples and include the Terraform registry information and proper version constraint. A version constraint would generally look like this `~> 1.0`

## Example

Multi-region Example utilizing both the integration module to make the account level integration in DataDog and the metrics streaming module to create the firehose and metrics stream in each region.
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
  version           = "1.0.0"
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
  version                              = "1.0.0"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-us-east-1${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_app_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_app_key"]
  datadog_api_url                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_url"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.us-east-1
  }
}

module "datadog_integration_us_west_2" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.0"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-us-west-2${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_app_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_app_key"]
  datadog_api_url                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_url"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.us-west-2
  }
}

module "datadog_integration_ca_central_1" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.0"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-ca-central-1${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_app_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_app_key"]
  datadog_api_url                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_url"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.ca-central-1
  }
}

module "datadog_integration_sa-east-1" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.0"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-sa-east-1${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_app_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_app_key"]
  datadog_api_url                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_url"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.sa-east-1
  }
}

module "datadog_integration_eu_west_2" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.0"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-eu-west-2${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_app_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_app_key"]
  datadog_api_url                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_url"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.eu-west-2
  }
}

module "datadog_integration_eu_central_1" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.0"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-eu-central-1${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_app_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_app_key"]
  datadog_api_url                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_url"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.eu-central-1
  }
}

module "datadog_integration_ap_southeast_1" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.0"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-ap-southeast-1${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_app_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_app_key"]
  datadog_api_url                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_url"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.ap-southeast-1
  }
}

module "datadog_integration_ap_southeast_2" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.0"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-ap-southeast-2${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_app_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_app_key"]
  datadog_api_url                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_url"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.ap-southeast-2
  }
}

module "datadog_integration_ap_northeast_1" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.0"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-ap-northeast-1${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_app_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_app_key"]
  datadog_api_url                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_url"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.ap-northeast-1
  }
}

module "datadog_integration_ap_northeast_2" {
  # source                               = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  source                               = "StratusGrid/firehose-datadog-metrics-streaming/aws"
  version                              = "1.0.0"
  name                                 = "${var.name_prefix}-metrics-${data.aws_caller_identity.current.account_id}-ap-northeast-2${local.name_suffix}"
  input_tags                           = local.common_tags
  datadog_api_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_key"]
  datadog_app_key                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_app_key"]
  datadog_api_url                      = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_api_url"]
  datadog_firehose_delivery_stream_url = jsondecode(data.aws_secretsmanager_secret_version.datadog_secret.secret_string)["datadog_firehose_delivery_stream_url"]
  providers = {
    aws = aws.ap-northeast-2
  }
}
```

## StratusGrid Standards we assume

- This repo is designed to be built upon the [StratusGrid Account Starter Template](https://github.com/StratusGrid/terraform-account-starter), this base template configures the remote backend and SOPS baseline requirements.
- All resource names and name tags shall use `_` and not `-`s
- The old naming standard for common files such as inputs, outputs, providers, etc was to prefix them with a `-`, this is no longer true as it's not POSIX compliant. Our pre-commit hooks will fail with this old standard.
- StratusGrid generally follows the TerraForm standards outlined [here](https://www.terraform-best-practices.com/naming)

## Repo Knowledge

This repo has several base requirements

- This repo is based upon the AWS `~> 4.9.0` provider
- The following packages are installed via brew: `tflint`, `terrascan`, `terraform-docs`, `gitleaks`, `tfsec`, `pre-commit`, `sops`, `go`
- Install `bash` through Brew for Bash 5.0, otherwise it will fail with the error that looks like `declare: -g: invalid option`
- If you need more tflint plugins, please edit the `.tflint.hcl` file with the instructions from [here](https://github.com/terraform-linters/tflint)
- It's highly recommend that you follow the Git Pre-Commit Instructions below, these will run in GitHub though they should be ran locally to reduce issues
- By default Terraform docs will always run so our auto generated docs are always up to date
- This repo has been tested with [awsume](https://stratusgrid.atlassian.net/wiki/spaces/TK/pages/1564966913/Awsume)
- The Terraform module standard is to place everything in the `main.tf` file, and this works well for small modules. Though StratusGrid suggests breaking it out into multiple files if the module is larger or touches many resources such as data blocks.
- StratusGrid requires the tag logic be used and every resource within the module be tagged with `local.tags`

### TFSec

See the pre-commit tfsec documentation [here](https://github.com/antonbabenko/pre-commit-terraform#terraform_tfsec), this includes on how to bypass warnings

## Apply this template via Terraform

### Before this is applied, you need to configure the git hook on your local machine

```bash
#Verify you have bash5
brew install bash

# Test your pre-commit hooks - This will force them to run on all files
pre-commit run --all-files

# Add your pre-commit hooks forever
pre-commit install
```

### Template Documentation

A sample template Git Repo with how we should setup client infrastructure, in this case it's shared infrastructure.
More details are available [here](https://stratusgrid.atlassian.net/wiki/spaces/MS/pages/2065694728/MSP+Client+Setup+-+Procedure) in confluence.

## Documentation

This repo is self documenting via Terraform Docs, please see the note at the bottom.

### `LICENSE`

This is the standard Apache 2.0 License as defined [here](https://stratusgrid.atlassian.net/wiki/spaces/TK/pages/2121728017/StratusGrid+Terraform+Module+Requirements).

### `outputs.tf`

The StratusGrid standard for Terraform Outputs.

### `README.md`

It's this file! I'm always updated via TF Docs!

### `tags.tf`

The StratusGrid standard for provider/module level tagging. This file contains logic to always merge the repo URL.

### `variables.tf`

All variables related to this repo for all facets.
One day this should be broken up into each file, maybe maybe not.

### `versions.tf`

This file contains the required providers and their versions. Providers need to be specified otherwise provider overrides can not be done.

## Documentation of Misc Config Files

This section is supposed to outline what the misc configuration files do and what is there purpose

### `.config/.terraform-docs.yml`

This file auto generates your `README.md` file.

### `.config/terrascan.yaml`

This file has all of the configuration options required for Terrascan, this is where you would skip rules to.

### `.github/sync-repo-settings.yaml`

This file is our standard for how GitHub branch protection rules should be setup.

### `.github/workflows/pre-commit.yml`

This file contains the instructions for Github workflows, in specific this file run pre-commit and will allow the PR to pass or fail. This is a safety check and extras for if pre-commit isn't run locally.

### `.vscode/settings.json`

This file is a vscode workspace settings file.

### `examples/*`

The files in here are used by `.config/terraform-docs.yml` for generating the `README.md`. All files must end in `.tfnot` so Terraform validate doesn't trip on them since they're purely example files.

### `.gitignore`

This is your gitignore, and contains a slew of default standards.

### `.pre-commit-config.yaml`

This file is the GIT pre-commit file and contains all of it's configuration options

### `.prettierignore`

This file is the ignore file for the prettier pre-commit actions. Specific files like our SOPS config files have to be ignored.

### `.tflint.hcl`

This file contains the plugin data for TFLint to run.

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
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | Datadog API Key | `string` | n/a | yes |
| <a name="input_datadog_api_url"></a> [datadog\_api\_url](#input\_datadog\_api\_url) | Datadog API URL | `string` | n/a | yes |
| <a name="input_datadog_app_key"></a> [datadog\_app\_key](#input\_datadog\_app\_key) | Datadog Application Key | `string` | n/a | yes |
| <a name="input_datadog_firehose_delivery_stream_url"></a> [datadog\_firehose\_delivery\_stream\_url](#input\_datadog\_firehose\_delivery\_stream\_url) | Datadog URL for the Firehose Delivery stream to send metrics. Marked sensitive because the some endpoints requires a key in the url. | `string` | n/a | yes |
| <a name="input_input_tags"></a> [input\_tags](#input\_input\_tags) | Map of tags to apply to resources | `map(string)` | <pre>{<br>  "Developer": "StratusGrid",<br>  "Provisioner": "Terraform"<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | name to prepend to all resource names within module. NOTE: For this DataDog firehose integration, it is recommended to use a format that includes the AWS Account number and region since it is account and region specific. | `string` | n/a | yes |

## Outputs

No outputs.

---

Note, manual changes to the README will be overwritten when the documentation is updated. To update the documentation, run `terraform-docs -c .config/.terraform-docs.yml`
<!-- END_TF_DOCS -->