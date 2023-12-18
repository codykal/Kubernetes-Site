resource "aws_lambda_function" "push_to_efs" {
  function_name = "push_to_efs"
  role          = aws_iam_role.Lambda_Role.arn
  handler       = "push_to_efs.lambda_handler"
  //TODO Make python script to push changes from S3 to EFS.
  runtime          = "python3.9"
  source_code_hash = filebase64sha256(data.archive_file.push_to_efs.output_path)
  filename = data.archive_file.push_to_efs.output_path
  timeout = 90
  vpc_config {
    subnet_ids = [aws_subnet.Public1.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.site_files.bucket
    }
  }

  file_system_config {
    arn              = aws_efs_access_point.EFS_AccessPoint.arn
    local_mount_path = "/mnt/efs"
  }
}

data "archive_file" "push_to_efs" {
  type = "zip"
  source_file = "./push_to_efs.py"
  output_path = "./lambda_function.zip"
}   

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.push_to_efs.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.site_files.arn
}

