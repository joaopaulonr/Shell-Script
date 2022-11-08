#!/bin/bash
function Add(){
    echo -e "$A\t$I" >> host.db;
}
function list(){
    cat host.db | sort | uniq;
}
function delete(){
    Fieldremove=$(cat host.db | grep -i "$D")
    sed -i -r "/${Fieldremove}/d" host.db
}
function reverse(){
    nomeHost=$(cat host.db | grep -i "$R" | cut -f1)
    echo $nomeHost
}
function find(){
    ipAddr=$(cat host.db | grep -i "$F" | cut -f2)
    echo $ipAddr
}
while getopts ":a:i:d:r:l" opt; do
    case $opt in
    a)
    A=$OPTARG ;;
    i)
    I=$OPTARG
    Add ;;
    d)
    D=$OPTARG
    delete ;;
    l) 
    list ;;
    r)
    R=$OPTARG
    reverse ;;
    ?)
    F=$OPTARG
    find ;;
    esac
done


