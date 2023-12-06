import boto3
import os
import shutil
import logging

logger = logging.getLogger()
logger.setLevel(logging.DEBUG) 
logger.info(f"Current UID: {os.getuid()} GID: {os.getgid()}")

def lambda_handler(event, context):
    logger.info(f"Recieved event: {event}")
    # Retrieve the S3 bucket and key from the event
    s3_bucket = event['Records'][0]['s3']['bucket']['name']
    s3_key = event['Records'][0]['s3']['object']['key']
    
    logger.info(f"Processing files: {s3_key} from bucket {s3_bucket}")
    
    # Set the download path in the /tmp directory
    download_path = '/tmp/' + os.path.basename(s3_key)
    logger.info(f"Set the download path to {download_path}")
    
    # Create an S3 client
    s3_client = boto3.client('s3')
    logger.info(f"Initialized Boto Client")
    logger.info(os.path.ismount("/mnt/efs"))
    logger.info(os.listdir("/mnt/efs"))

    
    try:
        # Download the file from S3
        s3_client.download_file(s3_bucket, s3_key, download_path)
        logger.info(f"File downloaded successfully: {download_path}")
    except Exception as e:
        logger.error(f"Error downloading file: {str(e)}")
        return {
            'statusCode': 500,
            'body': 'Error downloading file'
        }
    
    # # Additional logic
    # with open(download_path, 'r') as file:
    #     file_content = file.read()
    #     print(f"File content: {file_content}")
    
    # Move the file to the /mnt/efs directory
    destination_path = '/mnt/efs' 
    try:
        shutil.move(download_path, destination_path)
        logger.info(f"File moved to: {destination_path}")
    except Exception as e:
        logger.error(f"Error moving file: {str(e)}")
        return {
            'statusCode': 500,
            'body': 'Error moving file'
        }
    logger.info("After : " + str(os.listdir("/mnt/efs")))
    
    # Add more logic here as needed
    
    return {
        'statusCode': 200,
        'body': 'File downloaded and moved successfully'
    }