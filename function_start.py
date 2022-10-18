import json

def handler(event, context):
    serverID = event.server_identifier
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda2!')
    }
