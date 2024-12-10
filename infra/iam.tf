resource "aws_iam_policy" "contabilidade_lambda_policy" {
  name        = "${var.ENV_NAME}-lambda-policy-rdg"
  description = "${var.ENV_NAME}-lambda-policy-rdg"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:CopyObject",
          "s3:HeadObject"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "${aws_s3_bucket.contabilidade_s3_bucket.arn}",
          "${aws_s3_bucket.contabilidade_s3_bucket.arn}/*"
        ]
      },
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:DeleteItem"
        ],
        "Resource" : "${aws_dynamodb_table.contabilidade_ddb_table.arn}"
      },
      {
        "Effect" : "Allow"
        "Action" : [
          "sns:Publish",
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ],
        "Resource" : [
          "${aws_sns_topic.contabilidade_error_notification.arn}",
          "${aws_sqs_queue.contabilidade_queue.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "contabilidade_lambda_role" {
  name = "${var.ENV_NAME}-lambda-role-rdg"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "contabilidade_lambda_iam_policy_basic_execution" {
  role       = aws_iam_role.contabilidade_lambda_role.id
  policy_arn = aws_iam_policy.contabilidade_lambda_policy.arn
}
###################
