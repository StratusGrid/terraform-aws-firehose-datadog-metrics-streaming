locals {
  tags = merge(var.input_tags, {
    "ModuleSourceRepo" = "github.com/StratusGrid/terraform-aws-firehose-datadog-metrics-streaming"
  })
}