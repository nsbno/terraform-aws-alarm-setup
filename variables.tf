variable "name_prefix" {
  description = "The name of the service"
  type = string
}

variable "slack_lambda_name" {
  description = "The name of the lambda that sends alarms to slack"
  type = string

  default = null
}

variable "pager_duty_endpoint_urls" {
  description = "URLs to your pager duty endpoints"
  type = object({
    critical = string
    degraded = string
  })

  default = null
}
