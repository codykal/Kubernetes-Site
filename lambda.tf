resource "aws_lambda_function" "push_to_efs" {
  function_name = "push_to_efs"
  role          = aws_iam_role.Lambda_Role.id
  handler       = "push_to_efs.lambda_handler"
  //TODO Make python script to push changes from S3 to EFS.
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("./lambdafunction.zip")
  filename = "./lambdafunction.zip"

  file_system_config {
    arn              = aws_efs_file_system.EFS-Filesystem.arn
    local_mount_path = "/mnt/efs"
  }
}