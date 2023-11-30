resource "aws_lambda_function" "push_to_efs" {
  function_name = "push_to_efs"
  role          = aws_iam_role.Lambda_Role.arn
  handler       = "push_to_efs.lambda_handler"
  //TODO Make python script to push changes from S3 to EFS.
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("./lambdafunction.zip")
  filename = "./lambdafunction.zip"
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
