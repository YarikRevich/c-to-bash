#!/bin/bash
    
d=$(( 5 + 1 ))
    
# Describes foo function.
function foo() {
    echo $((d))
}
    
function main() {
    local g=$(foo)
    
    for (( i=g; i < 10; i++ )); do
        echo "Hello world"
    done
    
    if [[ $(( 12 )) == $(( 12 )) ]]; then
        echo "It works"
    fi
    
    local i=$(( 10 ))
    
    while (( i < 20 )); do
        echo "Slava Ukraini!"
        (( i++ ))
    
    done
    
    echo $((1))
}
    
main
