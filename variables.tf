variable "name" {
  description = "name to prepend to all resource names within module. NOTE: For this DataDog firehose integration, it is recommended to use a format that includes the AWS Account number and region since it is account and region specific."
  type        = string
}

variable "input_tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default = {
    Developer   = "StratusGrid"
    Provisioner = "Terraform"
  }
}

#CloudWatch Metrics Variables
variable "cw_namespace_exclude_filters" {
  type = list(object({
    metric_names = list(string),
    namespace    = string
  }))
  description = "Pairings of Namespaces and Metrics which should be excluded from the CloudWatch Metrics Stream."
  default     = []
}

#DataDog Variables
variable "datadog_api_key" {
  type        = string
  description = "Datadog API Key"
  sensitive   = true
}

variable "datadog_firehose_delivery_stream_url" {
  type        = string
  description = "Datadog URL for the Firehose Delivery stream to send metrics. Marked sensitive because the some endpoints requires a key in the url."
  sensitive   = true
}
