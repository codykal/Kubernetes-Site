import boto3
import os

def lambda_handler(event, context):
    s3_client = boto3.client('s3')
    efs_path = "/mnt/efs/"  # Path to your EFS mount point
    bucket_name = os.environ['S3_BUCKET_NAME']  # Specify your bucket name here

    # List all objects in the S3 bucket
    objects = s3_client.list_objects_v2(Bucket=bucket_name)

    if 'Contents' in objects:
        for obj in objects['Contents']:
            file_key = obj['Key']
            local_file_path = "/tmp/" + file_key.split('/')[-1]

            efs_directory = os.path.join(efs_path, os.path.dirname(file_key))
            if not os.path.exists(efs_directory):
                os.makedirs(efs_directory)

            # Download the file from S3 to the Lambda's temporary storage
            s3_client.download_file(bucket_name, file_key, local_file_path)



            #Copy the file from Lambda's temporary storage to EFS
            efs_file_path = os.path.join(efs_path, file_key)
            with open(local_file_path, 'rb') as file_data:
                with open(efs_file_path, 'wb') as efs_file:
                    efs_file.write(file_data.read())


    # Optional: Add cleanup, logging, error handling, etc.

    return {
        'statusCode': 200,
        'body': 'Files processed successfully'
    }