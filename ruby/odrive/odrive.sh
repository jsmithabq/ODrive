#!/bin/sh -f

echo "Running ODrive..."

test -d downloads || mkdir downloads
test -d uploads || mkdir uploads

ruby -I . odriveapp.rb

