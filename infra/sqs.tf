resource "aws_sqs_queue" "contabilidade_queue" {
  name = "reprocess-queue"
}

resource "aws_sqs_queue_policy" "contabilidade_sqs_policy" {
  queue_url = aws_sqs_queue.contabilidade_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "SQS:SendMessage"
        Resource  = aws_sqs_queue.contabilidade_queue.arn
        Principal = "*"
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = "${aws_sns_topic.contabilidade_error_notification.arn}"
          }
        }
      }
    ]
  })
}