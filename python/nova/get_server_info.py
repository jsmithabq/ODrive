#!/usr/bin/python

import httplib
import json

headers = {
    'Content-Type': 'application/json',
    'X-Auth-Token': '6ecf897da2a64a36a915044adcdfcca7'
}
conn = httplib.HTTPConnection("cloudhost.example.com:8774")
conn.request("GET",
    "/v2/f1bdabd926fd46749edb97c4270c6be4/servers/f33a2f0c-8048-4f6b-b270-e0eb9b86224d",
    None, headers)
response = conn.getresponse()
print response.status, response.reason
data = response.read()
dd = json.loads(data)
conn.close()
print "Response data:"
print json.dumps(dd, indent=2)
