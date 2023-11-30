//Lambda IAM roles and Policies
resource "aws_iam_policy" "Lambda_S3_EFS_Access_Policy" {
  name = "Lambda_S3_EFS_Access_Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.site_files.arn,
          "${aws_s3_bucket.site_files.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ],
        Resource = aws_efs_file_system.EFS-Filesystem.arn
      }
    ]
  })
}

resource "aws_iam_role" "Lambda_Role" {
  name = "Lambda_Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "EFS_S3_Policy_Attachment" {
  name       = "EFS_S3_Policy_Attachment"
  policy_arn = aws_iam_policy.Lambda_S3_EFS_Access_Policy.arn
}