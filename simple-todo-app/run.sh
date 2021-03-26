#/bin/bash

tonos-cli --url http://5.181.252.104 debot fetch `cat todoDebot.log  | grep "Raw address:" | cut -d ' ' -f 3`
