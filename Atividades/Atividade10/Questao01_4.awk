#!/usr/bin/awk
/^Oct (11|12).+?sshd.+?session opened.+?for user/ {print}