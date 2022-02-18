terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
}

/*
 * = Topics
 */

resource "aws_sns_topic" "degraded" {
  name = "${var.name_prefix}-degraded-alarms"
}

resource "aws_sns_topic" "critical" {
  name = "${var.name_prefix}-critical-alarms"
}


/*
 * = Slack Subscription
 */
# Lambda to send notification of alarms to Slack.
data "aws_lambda_function" "slack" {
  count = var.slack_lambda_name == null ? 0 : 1

  function_name = var.slack_lambda_name
}

# Permission to lambda to invoke from SNS degraded_alarms
resource "aws_lambda_permission" "allow_sns_trigger" {
  for_each = var.slack_lambda_name == null ? {} : {
    critical = aws_sns_topic.critical.arn
    degraded = aws_sns_topic.degraded.arn
  }

  principal     = "sns.amazonaws.com"
  source_arn    = each.value

  function_name = data.aws_lambda_function.slack[0].arn
  action        = "lambda:InvokeFunction"
}

# Subscribe SNS Topic for Critical Alarms to lambda.
resource "aws_sns_topic_subscription" "slack" {
  for_each = var.slack_lambda_name == null ? {} : {
    critical = aws_sns_topic.critical.arn
    degraded = aws_sns_topic.degraded.arn
  }

  topic_arn = each.value
  protocol  = "lambda"
  endpoint  = data.aws_lambda_function.slack[0].arn
}

/*
 * = Pager Duty Subscription
 */
resource "aws_sns_topic_subscription" "pagerduty" {
  for_each = var.pager_duty_endpoint_urls == null ? {} : {
    critical = {
      sns = aws_sns_topic.critical.arn
      url = var.pager_duty_endpoint_urls.critical
    }
    degraded = {
      sns = aws_sns_topic.degraded.arn
      url = var.pager_duty_endpoint_urls.degraded
    }
  }

  topic_arn              = each.value.sns
  protocol               = "https"
  endpoint               = each.value.url

  endpoint_auto_confirms = true
}
