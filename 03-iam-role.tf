# Create IAM Role for Lambda with EC2 access --IAM role
resource "aws_iam_role" "lambda_ec2_role" {
    name = "ebs-compliance-lambda-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
        }]
    })
}
# Attach policy to allow modifying EC2 volumes
resource "aws_iam_role_policy" "lambda_ec2_policy" {
    name = "ebs-modify-policy"
    role = aws_iam_role.lambda_ec2_role.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = ["ec2:DescribeVolumes", "ec2:ModifyVolume"]
            Resource = "*"
        }]
        
    })
}

