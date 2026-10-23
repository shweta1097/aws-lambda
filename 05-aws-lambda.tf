# Provision the Lambda function
resource "aws_lambda_function"  "compliance_lambda" {
    function_name = "ebs-volume-compliance-check"
    filename = data.archive_file.lamda_zip.output_path
    role = aws_iam_role.lambda_ec2_role.arn
    handler = "lambda-function.lambda_handler"
    runtime = "python3.14"
    source_code_hash = data.archive_file.lamda_zip.output_base64sha256

}

# Create EventBridge Rule for EC2 CreateVolume events --from CloudTrail
resource "aws_cloudwatch_event_rule" "ebs_create_rule" {
    name = "ebs-volume-creation-rule"
    description = "Trigger Lambda on EBS volume creation"
    event_pattern = jsonencode({
        source = ["aws.ec2"]
        detail-type = ["AWS API Call via CloudTrail"]
        detail = {
            eventSource = ["ec2.amazonaws.com"]
            eventName = ["CreateVolume"]
        }
    })
}
# Link EventBridge to Lambda --target
resource "aws_cloudwatch_event_target" "target_lambda" {
    rule = aws_cloudwatch_event_rule.ebs_create_rule.name
    target_id = "SendToLambda" // Unique identifier for the multiple targets
    arn = aws_lambda_function.compliance_lambda.arn
}

# Grant EventBridge permission to invoke Lambda --lambda invoke permission
resource "aws_lambda_permission" "invoke_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.compliance_lambda.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.ebs_create_rule.arn // Restrict permission to the specific EventBridge rule

}
