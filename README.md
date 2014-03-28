ODrive
------

Summary
-------

ODrive provides an alternative front-end to object-storage services
such as OpenStack Swift.

Todo
----

Currently, ODrive only provides drivers for Swift.  The objective is to
support Ceph RADOSGW, as well as other services as they come to market.

Overview
--------

ODrive provides
  1. A Ruby application server implemented with Sinatra.
  2. A RESTful front-end, which, with driver support, can
     support multiple object-storage services, providing
     common services across object-storage back-end services.
  3. An HTML web interface to object services.

Contents
--------

* ./python -- Miscelleaneous Python scripts loosely affiliated with ODrive, OpenStack, etc.
* ./ruby/odrive -- The ODrive application server, client programs, etc.
* ./ruby/<other> -- Miscelleanous test code

See Also
--------

See ./ruby/README.txt for information on launching the application server.

