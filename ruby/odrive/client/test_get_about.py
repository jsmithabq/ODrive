#!/usr/bin/env python

import httplib

host = 'localhost'
port = '6799'

http = httplib.HTTPConnection(host, port)

http.request("GET", "/rest/about.xml")
resp = http.getresponse()
print resp.status, resp.reason
data = resp.read()
print data

