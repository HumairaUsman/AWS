# YouTube to S3 Audio Transproter with API Gateway & AWS Lambda
This Python code implements a serverless function using AWS Lambda that allows users to download audio from YouTube videos and convert them to MP3 format. 
The downloaded MP3 files are then uploaded to a designated S3 bucket for storage.

## Important Note: 
Downloading and converting copyrighted content without permission is illegal. Use this project responsibly and only with videos that you have the rights to convert.

## Requirements:

- AWS Account with API Gateway, Lambda and S3 Services enabled
- Python 3.6 or later
- boto3 library (`pip install boto3`)
- pytube library (`pip install pytube`)

## Setup & Installation
1. Lambda Configuration
- Create a Lambda function named youtube-to-mp3-converter.
- Add an Environment Variable under the "Configuration" tab:
- destination_bucket: Name of your target S3 bucket.
- Attach an IAM Policy to the Lambda role allowing s3:PutObject permissions.

2. API Gateway Integration (The Entry Point)
- To trigger this project via an API call:
- Create a REST API in API Gateway.
- Create a /convert resource and a POST method.
- Deploy the API to a prod stage and copy your Invoke URL.
- Important: Enable Lambda Proxy Integration in the POST method setup.


3. Adding the Pytube Layer
- Because pytube is not a standard AWS library, you must add it as a Layer:
- Create a local folder and install the library: pip install pytube -t ./python.
- Zip the folder: zip -r pytube_layer.zip python/.
- Upload the .zip file as a Lambda Layer and attach it to your function.

## Deployment:

- Create a new Lambda function in your AWS account and name it appropriately (e.g., youtube-to-s3-audio).
- Choose Python 3.6 or later as the runtime environment.
- Copy and paste the provided Python code into the function's code editor.
- Configure the Lambda function with an environment variable named destination_bucket containing the name of your S3 bucket for storing the converted MP3 files.
- Grant the Lambda function appropriate permissions to access S3 using an IAM role.

## Limitations:

- This function uses `pytube` which may have limitations on downloadable video formats and resolutions.
- Converting and uploading large video files might exceed Lambda execution time limits.

## Security Considerations:

Downloading copyrighted content without permission is illegal. Use this project responsibly with videos you have the rights to convert.
Implement proper IAM roles and permissions for the Lambda function to access S3 securely.


