import boto3
import os
client = boto3.client('dynamodb')

def handler(event, context):
    serverIdentifier = event['server_identifier']
    data = client.scan(
        TableName = os.environ['TABLE_NAME'],
        FilterExpression='dnsName = :name',
        ExpressionAttributeValues = {':name':{'S':serverIdentifier}}
    )
    items = data["Items"]
    for item in items:
        ec2ID = item["ec2ID"]["S"]
    return {
        'statusCode': 200
    }