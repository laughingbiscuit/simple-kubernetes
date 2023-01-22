FROM alpine

RUN apk add busybox-extras moreutils jq
RUN mkdir -p cgi-bin/
ADD httpd.conf .
ADD status cgi-bin/
ADD rabbits cgi-bin/
ADD secrets cgi-bin/
RUN echo "[]" > cgi-bin/rabbits.json

CMD httpd -c httpd.conf -p 8080 -f -h .
