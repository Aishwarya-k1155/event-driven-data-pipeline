# Read existing IAM role (DO NOT create)
data "aws_iam_role" "lambda_role" {
  name = "event-driven-data-pipeline-lambda-role"
}

# Lambda function
resource "aws_lambda_function" "s3_processor" {
  function_name = "s3-processor"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  role          = data.aws_iam_role.lambda_role.arn

  filename         = "${path.module}/../lambda/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/lambda_function.zip")
}

# Allow S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_data.arn
}

# S3 notification
resource "aws_s3_bucket_notification" "raw_bucket_notification" {
  bucket = aws_s3_bucket.raw_data.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
