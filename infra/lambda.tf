data "archive_file" "contabilidade_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/app_ada_lambda/src"
  output_path = "${path.module}/app_ada_lambda/app_ada_lambda.zip"
}

resource "aws_lambda_function" "contabilidade_save_bd_lambda" {
  filename         = "${path.module}/app_ada_lambda/app_ada_lambda.zip"
  source_code_hash = data.archive_file.contabilidade_lambda_zip.output_base64sha256
  function_name    = "${var.ENV_NAME}-save-bd-rdg"
  role             = aws_iam_role.contabilidade_lambda_role.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.9"
  environment {
    variables = {
      REGION              = "${var.AWS_REGION}"
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.contabilidade_ddb_table.name
      SNS_TOPIC_ARN       = aws_sns_topic.contabilidade_error_notification.arn
    }
  }
}

resource "aws_lambda_permission" "contabilidade_allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contabilidade_save_bd_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.contabilidade_s3_bucket.arn
}

resource "aws_s3_bucket_notification" "contabilidade_bucket_notification" {
  bucket = aws_s3_bucket.contabilidade_s3_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.contabilidade_save_bd_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.contabilidade_allow_bucket]
}