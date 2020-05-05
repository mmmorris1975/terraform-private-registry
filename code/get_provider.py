from data import api as db
from util.status import http_404, http_200


# The TF Registry API docs state that there is no need to handle query strings for these requests
def lambda_handler(event, context):
    ns = event['pathParameters']['namespace']
    name = event['pathParameters']['name']
    provider = event['pathParameters']['provider']

    if event['rawPath'].endswith('/versions'):
        # List all module versions
        m = db.get_module_versions(ns, name, provider, False)

        if len(m) < 1:
            return http_404()

        v = []
        for e in m:
            v.append({'version': e['version']})

        mod = {
            'source': '%s/%s/%s' % (ns, name, provider),
            'versions': v
        }

        # https://www.terraform.io/docs/registry/api.html#list-available-versions-for-a-specific-module
        return http_200({'modules': [mod]})
    else:
        m = db.get_module_versions(ns, name, provider, True)

        if len(m) < 1:
            return http_404()

        mod = m[0]

        if event['rawPath'].endswith('/download'):
            # Download latest module version
            loc = '/'.join(['', 'v1', 'modules', ns, name, provider, mod['version'], 'download'])
            return {
                'isBase64Encoded': False,
                'statusCode': 302,
                'headers': {
                    'Content-Type': 'text/html',
                    'Location': loc
                },
                'body': '<html><head></head><body><a href="%s"></a>Found</body></html>' % loc
            }
        else:
            # List latest module version
            return http_200(mod)


if __name__ == '__main__':
    pass
