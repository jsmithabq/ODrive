#!/bin/sh -f

echo "Generating metadata listing..."

ruby test_sequel_postgres_database_metadata.rb >| ../../../misc/Whatever-Table-Metadata.txt
