#!/bin/sh
set -ex

# Check if the API is up
curl -f "http://localhost/cgi-bin/status"

# Manage our rabbits

curl -f -XPOST localhost/cgi-bin/rabbits -d '{"id":1, "name":"bugs"}'
curl -f -XPOST localhost/cgi-bin/rabbits -d '{"id":2, "name":"bunny"}'
curl -f localhost/cgi-bin/rabbits 
curl -f localhost/cgi-bin/rabbits/1
curl -f -XDELETE localhost/cgi-bin/rabbits/1
curl -f localhost/cgi-bin/rabbits 
curl -f -XPOST localhost/cgi-bin/rabbits -d '{"id":1, "name":"bugs"}'
curl -f -XDELETE localhost/cgi-bin/rabbits
curl -f localhost/cgi-bin/rabbits 

# Get some protected secrets
curl -f -u "admin:password" 'http://localhost/cgi-bin/secrets'
