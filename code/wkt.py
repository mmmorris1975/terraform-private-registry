import json

from data import api as db


def lambda_handler(event, context):
    return json.dumps(db.wkt_config())
