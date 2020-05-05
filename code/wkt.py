import json

from data import api as db


def lambda_handler(event, context):
    cfg = db.wkt_config()
    print(cfg)
    return json.dumps(cfg)
