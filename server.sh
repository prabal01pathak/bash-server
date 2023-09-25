#!/bin/bash
#
rm -rf response

mkfifo response

function handleRequest() {
    # TODO: Do the stuff
    while read line; do
        trline=`echo $line | tr -d '[\r\n]'`
        echo "tr line is: $trline"
        if [ -z $trline ]; then
            break
        fi
    done
    echo  -e "HTTP/1.1 200\r\nContent-Type:text/html\r\n\r\n<h1>PONG<h2>" > response
}

echo "Listening on 3000 ...."
cat response | nc -lN 3000 | handleRequest
