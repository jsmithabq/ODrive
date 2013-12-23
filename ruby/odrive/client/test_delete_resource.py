#!/usr/bin/env python

#
# = Summary
#

import httplib
import json
import base64

host = 'localhost'
port = '6799'

resource = '/rest/containers/def/objects/test.txt'

credentials = base64.standard_b64encode("testuser:testy")

http = httplib.HTTPConnection(host, port)

headers = {
  'cloud_host': 'cloudhost.example.com',
  'cloud_tenant': 'demo', 'cloud_user': 'test', 'cloud_password': 'secret',
  'authorization': "Basic %s" % (credentials)} 

http.request("DELETE", resource, "", headers)
resp = http.getresponse()
print resp.status, resp.reason
data = resp.read()
print data

