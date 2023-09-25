#!/bin/bash
#
rm -rf response

mkfifo response

function handleRequest() {
    while read line; do
        trline=`echo $line | tr -d '[\r\n]'`
        echo "tr line is: $trline"
        [ -z "$trline" ] && break
        HEADLINE_REGEX='(.*?)\s(.*?)\sHTTP.*?'
         [[ "$trline" =~ $HEADLINE_REGEX ]] &&
            REQUEST=$(echo $trline | sed -E "s/$HEADLINE_REGEX/\1 \2/")
        echo "Request is: $REQUEST"
    done
    case "$REQUEST" in 
        "GET /") RESPONSE="HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<h1>PONG</h1>";;
              *) RESPONSE="HTTP/1.1 400 NotFound\r\n\r\n\r\nNot Found";; 
    esac
    echo -e  $RESPONSE > response
}

echo "Listening on 3000 ...."
cat response | nc -lN 3000 | handleRequest
