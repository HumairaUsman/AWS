import json
import os
import logging
import boto3
from pytube import YouTube
from botocore.exceptions import ClientError

# Initialize S3 client outside the handler for better performance
s3_client = boto3.client('s3')
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # 1. Configuration from Environment Variables
    destination_bucket = os.environ.get("destination_bucket")
    
    # 2. Parse the URL from the API Gateway POST body
    try:
        # API Gateway passes the body as a string
        body = json.loads(event.get("body", "{}"))
        video_url = body.get("url")
    except json.JSONDecodeError:
        return {"statusCode": 400, "body": json.dumps("Invalid JSON format")}

    if not video_url:
        return {"statusCode": 400, "body": json.dumps("Missing 'url' in request body")}

    try:
        # 3. Process YouTube Download
        yt = YouTube(video_url)
        video = yt.streams.filter(only_audio=True).first()
        
        destination = "/tmp"
        out_file = video.download(output_path=destination)
        
        # 4. Convert/Rename to MP3
        base, _ = os.path.splitext(out_file)
        new_file = base + '.mp3'
        os.rename(out_file, new_file)
        
        # 5. Upload to S3
        file_name = os.path.basename(new_file)
        upload_success = upload_to_s3(new_file, destination_bucket, file_name)
        
        # 6. Cleanup /tmp to save space
        if os.path.exists(new_file):
            os.remove(new_file)

        if upload_success:
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'Success',
                    'title': yt.title,
                    'file_name': file_name
                })
            }
        else:
            raise Exception("S3 upload failed")

    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def upload_to_s3(file_path, bucket, object_name):
    try:
        s3_client.upload_file(file_path, bucket, object_name)
        return True
    except ClientError as e:
        logger.error(e)
        return False