import json


def http_404():
    return {
        'isBase64Encoded': False,
        'statusCode': 404,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({'errors': ['Not Found']})
    }


def http_200(body):
    return {
        'isBase64Encoded': False,
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps(body)
    }
