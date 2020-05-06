import os

import boto3
from boto3.dynamodb.conditions import (Key)

ddb = boto3.resource('dynamodb', endpoint_url=os.getenv('DYNAMODB_URL'))
t = ddb.Table(os.getenv('TABLE_NAME'))


# Return module information for a given provider. If latest=True, only the info for the latest version is returned,
# otherwise info for all versions is provided.  Should be enough to data to satisfy:
# GET  <base_url>/:namespace/:name/:provider  (latest version for the provider)
# GET  <base_url>/:namespace/:name/:provider/versions  (all versions for the provider)
# GET  <base_url>/:namespace/:name/:provider/download  (latest version, returns enough data to build redirect URL)
#
# Returns list of dicts for module attributes (even for single-item/latest requests!)
def get_module_versions(ns, name, provider, latest=False):
    items = []
    if latest:
        i = get_module_version(ns, name, provider, 'latest')
        if len(i) > 0:
            items.append(i)
    else:
        res = t.query(
            KeyConditionExpression=Key('k').eq('%s/%s' % (ns, name)) & Key('s').begins_with('%s/' % provider),
            ReturnConsumedCapacity='NONE'
        )

        for e in res.get('Items'):
            # only consider items where the 'n' (name) attribute is present, filters out 'latest' items
            if len(e) > 0 and 'n' in e:
                items.append(_parse_item(ns, e))

    return items


# Return information for a specific module version.  Should provide enough data to satisfy:
# GET  <base_url>/:namespace/:name/:provider/:version  (should be able to do this directly)
# GET  <base_url>/:namespace/:name/:provider/:version/download  (data returned should be enough to build this response)
#
# Returns dict of attributes for the module version
def get_module_version(ns, name, provider, version):
    res = t.get_item(
        Key={
            'k': '%s/%s' % (ns, name),
            's': '%s/%s' % (provider, version)
        },
        ReturnConsumedCapacity='NONE'
    )

    if 'Item' in res:
        # support passing 'latest' as a version string, redirect to version set for the item
        if version.casefold() == 'latest':
            i = res['Item']
            return get_module_version(ns, name, provider, i.get('ver'))
        else:
            return _parse_item(ns, res['Item'])
    else:
        return {}


def update_download_count(ns, name, provider, version):
    t.update_item(
        Key={
            'k': '%s/%s' % (ns, name),
            's': '%s/%s' % (provider, version)
        },
        ReturnValues='NONE',
        ReturnConsumedCapacity="NONE",
        UpdateExpression="ADD dl :n",
        ExpressionAttributeValues={
            ':n': 1
        }
    )


def wkt_config():
    res = t.get_item(
        Key={
            'k': 'wkt',
            's': 'cfg'
        },
        ReturnConsumedCapacity="NONE"
    )

    cfg = {}

    if 'Item' in res:
        i = res['Item']

        if 'modules_v1' in i:
            cfg['modules.v1'] = i['modules_v1']

        if 'login_v1' in i and i['login_v1']['client'] is not None:
            cfg['login.v1'] = i['login_v1']
            cfg['login.v1']['grant_types'] = list(cfg['login.v1']['grant_types'])

            # DynamoDB and Python sets are unordered, so we have no idea if the data is in the proper order, fix it
            ports = []
            for e in cfg['login.v1']['ports']:
                ports.append(int(e))

            ports.sort()
            cfg['login.v1']['ports'] = ports

    return cfg


def _parse_item(ns, i):
    return {
        "id": '/'.join([ns, i['n'], i['prv'], i['ver']]),
        "namespace": ns,
        "name": i['n'],
        "provider": i['prv'],
        "version": i['ver'],
        "owner": i.get('o', ''),
        "description": i.get('des', ''),
        "source": i.get('src', ''),
        "published_at": i.get('pub', None),
        "downloads": i.get('dl', 0),
        "verified": i.get('vfy', False)
    }

    # TODO
    # implement methods to support: (eventually, don't think these are on the critical path for registry implementation)
    #   GET  <base_url>
    #   GET  <base_url>/search
    #   GET  <base_url>/:namespace
    #   GET  <base_url>/:namespace/:name
    #
    # publish new module version
    #   must be unique version for a given namespace, module name, and provider, otherwise fail
    #   update 'latest' version to point to this new version
    #   POST to /:namespace/:name/:provider/:version ?
    #     body contains owner, description, source repo url
    #     returns composed id value (or error message, if applicable)
    #
    # delete module
    #   must support deleting at least a specific version
    #   should support deleting all versions for a given module name and/or provider
    #   would need to handle case where version referenced in latest is deleted
    #
    # update attributes for a module version
    #   limited ability for allowed users to update attributes (owner, description, source repo url only?)
    #     PUT (PATCH?) to /:namespace/:name/:provider/:version ?
    #       body contains attributes for the update
    #   explicitly disallow updating any generated or key attributes
    #   find some way to update downloads count attribute, but only from the api (no ability for user updates)
