resource "aws_efs_file_system" "EFS-Filesystem" {
  creation_token = "static-files"

  availability_zone_name = "us-west-2a"

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
}



resource "aws_efs_mount_target" "EFS-MountTarget" {
  file_system_id  = aws_efs_file_system.EFS-Filesystem.id
  subnet_id       = aws_subnet.Public1.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_access_point" "EFS_AccessPoint" {
    file_system_id = aws_efs_file_system.EFS-Filesystem.id

    posix_user {
      gid = 1001
      uid = 1001
    }

    root_directory {
      path = "/"
      creation_info {
        owner_gid = 1001
        owner_uid = 1001
        permissions = "0777"
      }
    }
}
