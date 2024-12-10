resource "aws_sns_topic" "contabilidade_error_notification" {
  name = "error-notification-topic"
}

resource "aws_sns_topic_subscription" "sqs_subscription" {
  topic_arn            = aws_sns_topic.contabilidade_error_notification.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.contabilidade_queue.arn
  raw_message_delivery = true
}
