#!/bin/bash
rm -rf response

mkfifo response

HEADLINE_REGEX='(.*?)\s(.*?)\sHTTP.*?'
CONTENT_LENGTH_REGEX='Content-Length:\s(.*?)'
BODY_REGEX='(.*?)=(.*?)'

function handle_POST_login() {
  RESPONSE=$(cat post-login.http | \
    sed "s/{{cookie_name}}/$INPUT_NAME/" | \
    sed "s/{{cookie_value}}/$INPUT_VALUE/")
}


function handleStaticFiles() {
    echo "HTTP/1.1 200 OK\r\nContent-Type: text/css\r\n\r\n$(cat login.css)"
}

function handleRequest() {
    while read line; do
        trline=`echo $line | tr -d '[\r\n]'`
        # echo "tr line is: $trline"
        [ -z "$trline" ] && break

        [[ "$trline" =~ $CONTENT_LENGTH_REGEX ]] &&
        CONTENT_LENGTH=`echo $trline | sed -E "s/$CONTENT_LENGTH_REGEX/\1/"`


        [[ "$trline" =~ $HEADLINE_REGEX ]] &&
           REQUEST=$(echo $trline | sed -E "s/$HEADLINE_REGEX/\1 \2/")
    done

    if [ ! -z $CONTENT_LENGTH ]; then
        while read -n$CONTENT_LENGTH -t1 body; do
            echo "body is: $body"
            INPUT_EMAIL=$(echo $body | sed -E "s/$BODY_REGEX/\1/")
            INPUT_PASSWORD=$(echo $body | sed -E "s/$BODY_REGEX/\2/")
        done

    fi
    echo "Request is: $REQUEST"
    echo "Content-Length: $CONTENT_LENGTH"
    echo "FORM IS"
    echo Email: $INPUT_EMAIL Password: $INPUT_PASSWORD
    case "$REQUEST" in 
        "GET /")                 RESPONSE="HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n$(cat login.html)";;
        "POST /login")           handle_POST_login;;
        "GET /static/login.css") RESPONSE=$(handleStaticFiles "$REQUEST");;
        *)                       RESPONSE="HTTP/1.1 400 NotFound\r\n\r\n\r\nNot Found";; 
    esac
    echo "response is: $RESPONSE"
    echo -e  $RESPONSE > response
}

echo "Listening on 3000 ...."

while true; do
    cat response | nc -lN 3000 | handleRequest
done
