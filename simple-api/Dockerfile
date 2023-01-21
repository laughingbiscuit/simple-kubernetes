FROM alpine

RUN apk add busybox-extras
RUN mkdir -p cgi-bin/
ADD httpd.conf .
ADD status cgi-bin/
ADD todos cgi-bin/
ADD secrets cgi-bin/
RUN touch cgi-bin/todos.csv

CMD httpd -c httpd.conf -p 8080 -f -h .
