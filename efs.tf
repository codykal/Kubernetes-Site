resource "aws_efs_file_system" "EFS_Filesystem" {
  creation_token = "static-files"

  availability_zone_name = "us-west-2a"

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
}



resource "aws_efs_mount_target" "EFS-MountTarget" {
  file_system_id  = aws_efs_file_system.EFS_Filesystem.id
  subnet_id       = aws_subnet.Public1.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_access_point" "EFS_AccessPoint" {
    file_system_id = aws_efs_file_system.EFS_Filesystem.id

    posix_user {
      gid = 1000
      uid = 1000
    }

    root_directory {
      // May have to change to "/efs" if lambda is having permission issues.
      path = "/"
      creation_info {
        owner_gid = 1000
        owner_uid = 1000
        permissions = "0777"
      }
    }
}
