#!/bin/bash

# gzip deflate br 

# netcat server
echo -e 'HTTP/1.1 200\r\nContent-Type: text/html\r\n\r\n<h1>PONG</h1>' | nc -lvkN 3000

