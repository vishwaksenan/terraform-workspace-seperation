# IAM Role for the Lambda function
resource "aws_iam_role" "iot_processor" {
  name = var.iot_processor_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Policy for the Lambda function (permissions to log to CloudWatch)
resource "aws_iam_policy" "iot_processor" {
  name        = var.iot_processor_policy_name
  description = "Permissions for the IoT data processing Lambda function"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*",
      },
      # Add other permissions your Lambda function might need here
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "iot_processor_attachment" {
  role       = aws_iam_role.iot_processor.name
  policy_arn = aws_iam_policy.iot_processor.arn
}

# IAM Role for the IoT Rule to invoke Lambda
resource "aws_iam_role" "iot_rule" {
  name = var.iot_rule_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "iot.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Policy allowing the IoT Rule to invoke the Lambda function
resource "aws_iam_policy" "iot_rule" {
  name        = var.iot_rule_policy_name
  description = "Permissions for the IoT Rule to invoke the Lambda function"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "lambda:InvokeFunction",
        Effect   = "Allow",
        Resource = aws_lambda_function.iot_processor.arn,
      },
    ]
  })
}

# Attach the policy to the IoT Rule role
resource "aws_iam_role_policy_attachment" "iot_rule_attachment" {
  role       = aws_iam_role.iot_rule.name
  policy_arn = aws_iam_policy.iot_rule.arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.lambda_function_path
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "iot_processor" {
  function_name = var.lambda_function_name
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  role          = aws_iam_role.iot_processor.arn
  filename      = data.archive_file.lambda_zip.output_path # Use the output from the data block

  environment {
    variables = {
      IOT_PROCESSING_LAMBDA = "true"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iot_thing" "my_sensor" {
  name = var.iot_thing_name
  attributes = {
    model            = "arduino-board" # Registering a arduino thing
    firmware_version = "1.0"
    location         = "London"
  }
}

resource "aws_iot_certificate" "device_cert" {
  active = true
}

resource "aws_iot_policy_attachment" "device_policy_attach" {
  policy = aws_iot_policy.device_policy.name
  target = aws_iot_certificate.device_cert.arn
}

# Create an IoT Policy (granting basic connect, publish, subscribe permissions - adjust as needed)
resource "aws_iot_policy" "device_policy" {
  name = var.iot_policy_name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "iot:Connect",
          "iot:Publish",
          "iot:Subscribe",
          "iot:Receive",
        ],
        Effect   = "Allow",
        Resource = "*", # Be as specific as possible in a real-world scenario
      },
    ]
  })
}

# Create an IoT Topic Rule to trigger the Lambda function
resource "aws_iot_topic_rule" "process_sensor_data" {
  name        = var.iot_rule_name
  enabled     = true
  sql         = "SELECT * FROM '${var.iot_topic_filter}'" # Using a variable for the topic filter
  sql_version = "2016-03-23"
  lambda {
    function_arn = aws_lambda_function.iot_processor.arn
  }
}
