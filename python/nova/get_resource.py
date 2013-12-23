#!/usr/bin/env python

import httplib
import json
import sys

if len(sys.argv) < 4:
    print """
    %s <host> <port> <auth-token> [<tenant-id>]
    """ % sys.argv[0]
    sys.exit(0)

headers = {
    'Content-Type': 'application/json',
    'X-Auth-Token': sys.argv[3]
}
try:
    status = 0
    host_port = "%s:%s" % (sys.argv[1], sys.argv[2])
    conn = httplib.HTTPConnection(host_port)
    ep = "/v2"
    if len(sys.argv) == 5:
        ep += "/" + sys.argv[4] + "/"
    while True:
        sys.stdout.write(
            "For 'http://%s%s', enter resource (or quit):" % (host_port, ep))
        sys.stdout.write("\n\n")
        resource = raw_input("==> ")
        if not resource:
            continue
        if resource == "quit":
            break
        try:
            #sys.stdout.write(ep + resource + "\n")
            conn.request("GET", ep + resource, None, headers)
            response = conn.getresponse()
            data = response.read()
            dd = json.loads(data)
            sys.stdout.write(json.dumps(dd, indent=2))
            sys.stdout.write("\n\n")
        except Exception as ex:
            sys.stdout.write("Resource not found: %s\n\n" % resource)
except Exception as ex:
    status = -1
    print "Exception:"
    print ex
    conn.close()
sys.exit(status)
