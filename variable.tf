variable "AWS_SECRET_KEY" {
  type    = string
  default = ""
}

variable "AWS_ACCESS_KEY" {
  type    = string
  default = ""
}

variable "aws_region" {
  type        = string
  default     = "eu-west-2" # Change to your desired AWS region
  description = "The AWS region to deploy resources in"
}

variable "lambda_runtime" {
  type        = string
  default     = "python3.9" # Choose your desired Lambda runtime
  description = "The runtime environment for the Lambda function"
}

variable "lambda_handler" {
  type        = string
  default     = "hello-world.lambda_handler" # Adjust based on your Lambda code
  description = "The handler function for the Lambda function"
}

variable "lambda_function_name" {
  type        = string
  default     = "iot-data-processor"
  description = "The name of the Lambda function"
}

variable "iot_policy_name" {
  type        = string
  default     = "device-policy"
  description = "The name of the IoT Policy"
}

variable "iot_rule_name" {
  type        = string
  default     = "process_sensor_data_rule"
  description = "The name of the IoT Rule"
}

variable "iot_topic_filter" {
  type        = string
  default     = "sensors/temperature" # Adjust to the MQTT topic your devices will use
  description = "The MQTT topic filter for the IoT Rule"
}

variable "lambda_function_path" {
  type        = string
  default     = "python-lambda" # Ensure this path is correct and it is relative to this folder.
  description = "The path to the Lambda function deployment package"
}

variable "iot_processor_role_name" {
  type        = string
  default     = "iot-processor-role"
  description = "The name of the IAM role for the Lambda function"
}

variable "iot_processor_policy_name" {
  type        = string
  default     = "iot-processor-policy"
  description = "The name of the IAM policy for the Lambda function"
}

variable "iot_rule_role_name" {
  type        = string
  default     = "iot-rule-role"
  description = "The name of the IAM role for the IoT Rule"
}

variable "iot_rule_policy_name" {
  type        = string
  default     = "iot-rule-policy"
  description = "The name of the IAM policy for the IoT Rule"
}

variable "iot_thing_name" {
  type        = string
  default     = "sensor-type"
  description = "The name of the IoT Thing Type"
}
