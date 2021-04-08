#/bin/bash
#
# This is a helper script
#
tonos-cli --url http://127.0.0.1 debot fetch `cat todoDebot.log  | grep "Raw address:" | cut -d ' ' -f 3`
