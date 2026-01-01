############################
# USE EXISTING IAM ROLE
############################
data "aws_iam_role" "lambda_role" {
  name = "event-driven-data-pipeline-lambda-role"
}

############################
# LAMBDA FUNCTION
############################
resource "aws_lambda_function" "s3_processor" {
  function_name = "s3-raw-to-processed"
  role          = data.aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename = "lambda.zip"

  depends_on = [
    aws_s3_bucket.raw_data,
    aws_s3_bucket.processed_data
  ]
}

############################
# ALLOW S3 TO INVOKE LAMBDA
############################
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_data.arn
}

############################
# S3 EVENT NOTIFICATION
############################
resource "aws_s3_bucket_notification" "raw_trigger" {
  bucket = aws_s3_bucket.raw_data.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}
