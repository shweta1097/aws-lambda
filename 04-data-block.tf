data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "archive_file" "lamda_zip" {
    type = "zip"
    source_file = "${path.module}/lambda-function.py"
    output_path = "${path.module}/lambda-function.zip"
}