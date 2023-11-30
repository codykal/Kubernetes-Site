resource "aws_s3_bucket" "site_files" {
  bucket = "codykall_site_files"
}

resource "aws_s3_bucket_ownership_controls" "site_files_controls" {
  bucket = aws_s3_bucket.site_files.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "site_files_acl" {
  depends_on = [ aws_s3_bucket_ownership_controls.site_files_controls ]
  bucket = aws_s3_bucket.site_files.id
  acl = "private"
}

resource "aws_s3_bucket_notification" "site_files_notification" {
  bucket = aws_s3_bucket.site_files.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.push_to_efs.arn
    events = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.push_to_efs.function_name
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.site_files.arn
}