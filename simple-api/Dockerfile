FROM alpine

RUN apk add busybox-extras moreutils jq
RUN mkdir -p cgi-bin/
ADD httpd.conf .
ADD status cgi-bin/
ADD rabbits cgi-bin/
ADD secrets cgi-bin/

CMD httpd -c httpd.conf -p 80 -f -h .
