resource "aws_lambda_function" "push_to_efs" {
  function_name = "push_to_efs"
  role = aws_iam_role.Lambda_Role.id
  //TODO Make python script to push changes from S3 to EFS.
}