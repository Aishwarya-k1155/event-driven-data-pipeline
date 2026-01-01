# ---------------------------
# IAM Role for Lambda
# ---------------------------
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# ---------------------------
# IAM Policy
# ---------------------------
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.raw_data.arn}/*",
          "${aws_s3_bucket.processed_data.arn}/*"
        ]
      }
    ]
  })
}

# ---------------------------
# Lambda Function
# ---------------------------
resource "aws_lambda_function" "processor" {
  function_name = "${var.project_name}-processor"

  filename         = "../lambda/lambda_function.zip"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = filebase64sha256("../lambda/lambda_function.zip")
}

# ---------------------------
# Allow S3 to invoke Lambda
# ---------------------------
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_data.arn
}

# ---------------------------
# S3 Trigger (RAW bucket)
# ---------------------------
resource "aws_s3_bucket_notification" "raw_trigger" {
  bucket = aws_s3_bucket.raw_data.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
