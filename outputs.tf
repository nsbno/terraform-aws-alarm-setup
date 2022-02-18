output "critical_sns_arn" {
  description = "A topic that indicates that the service is in critical condition."
  value = aws_sns_topic.critical.arn
}

output "degraded_sns_arn" {
  description = "A topic that is used to indicate that the service is in a degraded state"
  value = aws_sns_topic.degraded.arn
}
