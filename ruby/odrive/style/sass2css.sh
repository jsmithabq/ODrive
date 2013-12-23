#!/bin/sh -f

echo ""
echo "executing sass2css.rb on all matching files..."

for file in "$@"
do
  if [ -f $file ]; then
    echo $file
    ruby sass2css.rb $file
  fi
done
