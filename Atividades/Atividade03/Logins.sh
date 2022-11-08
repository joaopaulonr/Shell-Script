# Nota: 1,0
grep -v "sshd" auth.log 
grep -E "sshd.+?session opened.+?for user j" auth.log
grep -E "sshd.+?for root" auth.log
grep -E "Oct (11|12).+?sshd.+?session opened.+?for user" auth.log 
