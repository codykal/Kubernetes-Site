variable "efs_id" {
    description = "efs_id"
    type = string
    default = aws_efs_file_system.EFS-Filesystem.id
  
}