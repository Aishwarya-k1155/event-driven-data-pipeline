import json
import boto3

s3 = boto3.client('s3')

def lambda_handler(event, context):
    # Get bucket and object info
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']

    destination_bucket = "event-driven-data-pipeline-processed-data-1155"

    # Copy object from raw to processed bucket
    copy_source = {
        'Bucket': source_bucket,
        'Key': object_key
    }

    s3.copy_object(
        CopySource=copy_source,
        Bucket=destination_bucket,
        Key=object_key
    )

    return {
        'statusCode': 200,
        'body': json.dumps('File processed successfully')
    }
