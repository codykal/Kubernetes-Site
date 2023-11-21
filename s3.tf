resource "aws_s3_bucket" "site_files" {
  bucket = "codykall_site_files"
}

resource "aws_s3_bucket_ownership_controls" "site_files_controls" {
  bucket = aws_s3_bucket.site_files.id
  rule {
    object_ownership = "BucketOwnerPreffered"
  }
}

resource "aws_s3_bucket_acl" "site_files_acl" {
  depends_on = [ aws_s3_bucket_ownership_controls.site_files_controls ]
  bucket = aws_s3_bucket.site_files.id
  acl = "private"
}