#!/bin/sh -f

echo "Running ODrive..."

test -d downloads || mkdir downloads
test -d uploads || mkdir uploads
test -d store || mkdir store

ruby -I . odriveapp.rb

