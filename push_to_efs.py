import boto3
import os

def lambda_handler(event, context):
    s3_client = boto3.client('s3')
    efs_path = "/mnt/efs"

    bucket_name = event['Records'][0]['s3']['bucket']['name']
    file_key = event['Records'][0]['s3']

     # Define the local path to temporarily store the file
    local_file_path = '/tmp/' + file_key
    s3_client.download_file(bucket_name, file_key, local_file_path)

    #Copy from Lambda temp storage to EFS
    efs_file_path = os.path.join(efs_path, file_key)
    with open(local_file_path, 'rb') as file_data:
        with open(efs_file_path, 'wb') as efs_file:
            efs_file.write(file_data.read())