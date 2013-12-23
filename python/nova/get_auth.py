#!/usr/bin/python

import httplib
import json
import sys

if len(sys.argv) < 2:
    print """
    %s <host>
    """ % sys.argv[0]
    sys.exit(0)

params = '{"auth":{"tenantName": "demo", \
    "passwordCredentials":{"username": "test", "password": "secret"}}}'
headers = {'Content-Type': 'application/json'}
conn = httplib.HTTPConnection("%s:35357" % sys.argv[1])
conn.request("POST", "/v2.0/tokens", params, headers)
response = conn.getresponse()
#print response.status, response.reason
data = response.read()
dd = json.loads(data)
conn.close()
print "Response data:"
print json.dumps(dd, indent=2)
print "Your token is: %s" % dd['access']['token']['id']
sc = dd['access']['serviceCatalog']
publicurl = ""
for ep in sc:
    if ep['name'] == "nova":
        publicurl = ep['endpoints'][0]['publicURL']
print "Your Nova URL is: %s" % publicurl
