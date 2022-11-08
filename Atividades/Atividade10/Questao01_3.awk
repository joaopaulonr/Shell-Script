#!/usr/bin/awk
/sshd.+?session opened.+?for user r/ {print}