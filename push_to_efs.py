import boto3
import os
import logging

#Initiate Logging
logger = logging.getLogger()
logger.setLevel(logging.INFO) 
logger.info(f"Current UID: {os.getuid()} GID: {os.getgid()}")

#Main Lambda Handle
def lambda_handler(event, context):
    logger.info(f"Recieved event: {event}")
    s3_client = boto3.client('s3')
    efs_path = "/mnt/efs/"  
    bucket_name = os.environ['S3_BUCKET_NAME'] 
    logger.info(os.path.ismount(efs_path))
    logger.info(os.listdir(efs_path))

    # List all objects in the S3 bucket
    objects = s3_client.list_objects_v2(Bucket=bucket_name)
    logger.info(f"Processing files: {objects} from bucket {bucket_name}")

    if 'Contents' in objects:
        for obj in objects['Contents']:
            file_key = obj['Key']
            local_file_path = "/tmp/" + file_key.split('/')[-1]
            logger.info(f"Set the download path to {local_file_path}")

            efs_directory = os.path.join(efs_path, os.path.dirname(file_key))
            if not os.path.exists(efs_directory):
                os.makedirs(efs_directory)

            # Download the file from S3 to the Lambda's temporary storage
            try:
                s3_client.download_file(bucket_name, file_key, local_file_path)
                logger.info(f"File downloaded successfully: {local_file_path}")
            except Exception as e:
                logger.error (f"Error downloading file: {str(e)}")



            #Copy the file from Lambda's temporary storage to EFS
            efs_file_path = os.path.join(efs_path, file_key)
            try:
                with open(local_file_path, 'rb') as file_data:
                    with open(efs_file_path, 'wb') as efs_file:
                        efs_file.write(file_data.read())
                        logger.info(f"{file_key} written successfully.")
            except Exception as e:
                logger.error (f"Error moving files to EFS: {str(e)}")
                return {
                    'statusCode': 500,
                    'body': 'Error moving files to EFS'
                }


    return {
        'statusCode': 200,
        'body': 'Files processed successfully'
    }