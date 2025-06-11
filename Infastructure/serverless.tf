locals {
  redeployment_hash = sha1(join(",", [
    aws_api_gateway_method.get.http_method,
    aws_api_gateway_method.post.http_method,
    aws_api_gateway_method.options.http_method,
    aws_api_gateway_integration.lambda_integration_get.uri,
    aws_api_gateway_integration.lambda_integration_post.uri,
    aws_api_gateway_integration.lambda_integration_options.uri,
    aws_api_gateway_method.get.api_key_required ? "true" : "false",
    aws_api_gateway_method.post.api_key_required ? "true" : "false",
    aws_lambda_function.test_lambda.source_code_hash
  ]))
}

# Create the API
resource "aws_api_gateway_rest_api" "my_api" {
  name = var.api_name
  description = "My API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Create a resource
resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id = aws_api_gateway_rest_api.my_api.root_resource_id
  # resource path
  path_part = var.resource_name

  depends_on = [ aws_api_gateway_rest_api.my_api ]
} 

# Create a Method1
resource "aws_api_gateway_method" "get" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = "GET"
  authorization = "NONE"
  api_key_required = true

  depends_on = [ aws_api_gateway_resource.root]
}


# Create a Method2
resource "aws_api_gateway_method" "post" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = "POST"
  authorization = "NONE"
  depends_on = [ aws_api_gateway_resource.root]
  api_key_required = true


}

# Create Method 3 
resource "aws_api_gateway_method" "options" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = "OPTIONS"
  authorization = "NONE"
  depends_on = [ aws_api_gateway_resource.root]

}

# GET Integration
resource "aws_api_gateway_integration" "lambda_integration_get" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST" # When you use type = "AWS_PROXY" (Lambda proxy integration), API Gateway always calls your Lambda via HTTP POST—even if the client’s method is GET.
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.test_lambda.invoke_arn
  depends_on = [ aws_lambda_function.test_lambda]
}

# POST Integration 
resource "aws_api_gateway_integration" "lambda_integration_post" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.test_lambda.invoke_arn
  depends_on = [ aws_lambda_function.test_lambda]
}

# Cors integration 

resource "aws_api_gateway_integration" "lambda_integration_options" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.options.http_method
  type                    = "MOCK"
  uri                     = aws_lambda_function.test_lambda.invoke_arn
  depends_on = [ aws_lambda_function.test_lambda]
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Define the method response 
resource "aws_api_gateway_method_response" "cors_method_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [ aws_api_gateway_integration.lambda_integration_options ]
}

# Define integration response 
resource "aws_api_gateway_integration_response" "cors_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.cors_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [ aws_api_gateway_method_response.cors_method_response ]
}


# Create a deployement
resource "aws_api_gateway_deployment" "my_api_deployement" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id

  triggers = {
    redeployment = local.redeployment_hash
  }

  depends_on = [
    aws_api_gateway_method.get,
    aws_api_gateway_integration.lambda_integration_get,
    aws_api_gateway_method.post,
    aws_api_gateway_integration.lambda_integration_post,
    aws_api_gateway_method.options,
    aws_api_gateway_integration.lambda_integration_options
  ]
}

resource "aws_api_gateway_usage_plan" "plan"{
  depends_on = [
    aws_api_gateway_deployment.my_api_deployement,
    aws_api_gateway_stage.my_api_stage
  ]
  name = "my_usage_plan"
  api_stages {
    stage = aws_api_gateway_stage.my_api_stage.stage_name
    api_id = aws_api_gateway_rest_api.my_api.id  
  }

  throttle_settings {
    burst_limit = 2
    rate_limit  = 1
  }
}

resource "aws_api_gateway_api_key" "api_key" {
  name = "Terraform-test-key"
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  depends_on = [aws_api_gateway_api_key.api_key]
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.plan.id
}

# Create a stage (Dev)
resource "aws_api_gateway_stage" "my_api_stage" {
  deployment_id = aws_api_gateway_deployment.my_api_deployement.id
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  stage_name    = "prod"
}

output "API_Invoke_URL" {
  value       = aws_api_gateway_stage.my_api_stage.invoke_url
  description = "description"
  depends_on  = [aws_api_gateway_stage.my_api_stage]
}
output "api_key" {
  value = aws_api_gateway_usage_plan_key.usage_plan_key.value
  description = "key of the api"
  depends_on = [aws_api_gateway_usage_plan_key.usage_plan_key] ##
}


# Create Lambda Function
resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../pytestt/app/lambda_function_payload.zip"
  function_name = var.Lambda_function_Name
  role          = aws_iam_role.Lambda_Update_DDB_Role.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("../pytestt/app/lambda_function_payload.zip")

  runtime = "python3.9"

  environment {
    variables = {
      TABLE_NAME = "My_Web_Visitors"
      PARTITION_KEY = "id"
      ITEM_NAME = "Website_Visitors"
      ATTRIBUTE_NAME = "visitors"
      API_PATH = aws_api_gateway_resource.root.path
    }
  }
}

# Allow APi Gateway to Trigger lambda
resource "aws_lambda_permission" "apigw_lambda_get" {
  statement_id  = "AllowGetExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.myregion}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.my_api.id}/*/${aws_api_gateway_method.get.http_method}/${aws_api_gateway_resource.root.path_part}"
}

# Allow APi Gateway to Trigger lambda
resource "aws_lambda_permission" "apigw_lambda_post" {
  statement_id  = "AllowPostExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.myregion}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.my_api.id}/*/${aws_api_gateway_method.post.http_method}/${aws_api_gateway_resource.root.path_part}"
}

# Deployment should wait for methods