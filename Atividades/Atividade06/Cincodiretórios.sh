#!/bin/bash
# Nota: 1,5
[ -d cinco ] || mkdir cinco

for a in $(seq 1 5)
do
    [ -d cinco/dir$a ] || mkdir cinco/dir$a
    for b in $(seq 1 4)
    do
        touch cinco/dir$a/arq$b.txt
        for c in $(seq 1 $b)
        do
            echo $b >> cinco/dir$a/arq$b.txt
        done
    done
done
