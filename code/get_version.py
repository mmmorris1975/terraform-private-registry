import os
import urllib.parse as url

from data import api as db
from util.status import http_404, http_200

dl_host = os.getenv('DOWNLOAD_HOST', 'localhost')


# The TF Registry API docs state that there is no need to handle query strings for these requests
def lambda_handler(event, context):
    ns = event['pathParameters']['namespace']
    name = event['pathParameters']['name']
    provider = event['pathParameters']['provider']
    ver = event['pathParameters']['version']

    m = db.get_module_version(ns, name, provider, ver)

    if len(m) < 1:
        return http_404()

    if event['rawPath'].endswith('/download'):
        p = '/'.join(['modules', ns, provider, "%s_%s.tar.bz2" % (name, ver)])

        qs = None
        if 'checksum' in m:
            qs = 'checksum=sha256:%s' % m['checksum']

        u = url.urlunsplit(('https', dl_host, p, qs, None))

        db.update_download_count(ns, name, provider, ver)

        return {
            'isBase64Encoded': False,
            'statusCode': 204,
            'headers': {'X-Terraform-Get': u}
        }
    else:
        return http_200(m)


if __name__ == '__main__':
    pass
