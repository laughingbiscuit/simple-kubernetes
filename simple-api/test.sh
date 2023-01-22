#!/bin/sh
set -ex

# Check if the API is up
curl -f "http://localhost:8080/cgi-bin/status"

# Manage our rabbits

curl -f -XPOST localhost:8080/cgi-bin/rabbits -d '{"id":1, "name":"bugs"}'
curl -f -XPOST localhost:8080/cgi-bin/rabbits -d '{"id":2, "name":"bunny"}'
curl -f localhost:8080/cgi-bin/rabbits 
curl -f localhost:8080/cgi-bin/rabbits/1
curl -f -XDELETE localhost:8080/cgi-bin/rabbits/1
curl -f localhost:8080/cgi-bin/rabbits 
curl -f -XPOST localhost:8080/cgi-bin/rabbits -d '{"id":1, "name":"bugs"}'
curl -f -XDELETE localhost:8080/cgi-bin/rabbits
curl -f localhost:8080/cgi-bin/rabbits 

# Get some protected secrets
curl -f -u "admin:password" 'http://localhost:8080/cgi-bin/secrets'
