#!/usr/bin/python

import httplib
import json

headers = {
    'Content-Type': 'application/json',
    'X-Auth-Token': '6ecf897da2a64a36a915044adcdfcca7'
}
conn = httplib.HTTPConnection("cloudhost.example.com:8774")
conn.request("GET", "/v2/f1bdabd926fd46749edb97c4270c6be4/images", None, headers)
response = conn.getresponse()
#print response.status, response.reason
data = response.read()
dd = json.loads(data)
conn.close()
print "Response data:"
print json.dumps(dd, indent=2)
