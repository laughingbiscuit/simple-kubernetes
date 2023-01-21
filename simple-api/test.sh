#!/bin/sh
set -ex

# Check if the API is up
curl -f "http://localhost:8080/cgi-bin/status"

# Add some things to the todo list
curl -f -XPOST 'http://localhost:8080/cgi-bin/todos?name=Exercise'
curl -f -XPOST 'http://localhost:8080/cgi-bin/todos?name=Dishes'

# Get the whole todo list
curl -f 'http://localhost:8080/cgi-bin/todos'

# Get some protected secrets
curl -f -u "admin:password" 'http://localhost:8080/cgi-bin/secrets'
