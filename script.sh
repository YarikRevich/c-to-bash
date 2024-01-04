#!/bin/bash

# Constants, which represent pre-defined regexp to analyse
# C code.
readonly PRINT_REGEXP_DECL_KEY=''


# readonly INTEGER_TYPE_DECL_KEY='int'
# readonly FLOAT_TYPE_DECL_KEY='float'
# readonly DOUBLE_TYPE_DECL_KEY='double'
# readonly STRING_TYPE_DECL_KEY='char *'

readonly IF_RESERVED_KEY='if'
readonly ELSE_RESERVED_KEY='else'
readonly FOR_RESERVED_KEY='for'
readonly WHILE_RESERVED_KEY='while'
readonly DO_RESERVED_KEY='do'
readonly RETURN_RESERVED_KEY='return'
readonly BREAK_RESERVED_KEY='break'
readonly CONTINUE_RESERVED_KEY='continue'
readonly VOID_RESERVED_KEY='void'
readonly FUNCTION_RESERVED_KEY='function'
readonly RIGHT_BRACKET_RESERVED_KEY='}'
readonly LEFT_BRACKET_RESERVED_KEY='{'

readonly LOCK_STORAGE_DECL_KEY='lock_storage'
readonly CYCLE_LOCK_STORAGE_DECL_KEY='cycle'

# Adds value to the global map.
function map_put() {
    alias "${1}$2"="$3"
}

# Retrieves value from the global map.
function map_get() {
    alias "${1}$2" | awk -F"'" '{ print $2; }'
}

# Retrieves all the keys from the global map.
function map_keys() {
    alias -p | grep $1 | cut -d'=' -f1 | awk -F"$1" '{print $2; }'
}

# Map of the scanned tokens
# declare -A tokens

# Validates given file to be processed.
function validate() {
    FILE=$1

    if [[ -z $1 ]]; then
        echo "Input file name was not provided"
        exit 1
    fi

    if [[ $FILE != *.c ]]; then
        echo "$FILE does not have required *.c extension"
        exit 1
    fi

    if [[ ! -f "$FILE" ]]; then
        echo "$FILE does not exist"
        exit 1
    fi

    gcc -fsyntax-only $FILE
    if [ ! $? -eq 0 ]; then
        exit 1
    fi
}

# Checks if the given line is empty.
function is_empty() {
    if [ -z "$1" ]; then
        echo "true"
    else 
        echo "false"
    fi
}

# Checks if the given line is ignorable.
function is_ignorable() {
    
}

# # Adds given token to a selected lock storage cell. 
# # The first argument is a lock storage type.
# # The second argument is a token ID.
# function add_lock_storage_token() {
#     map_put $LOCK_STORAGE_DECL_KEY $1 $2
# }

function increase_lock_number() {
    map_put $LOCK_STORAGE_DECL_KEY $1 $2
}

# Main entrypoint for the transpilator.
function main() {
    while read line 
    do
        # Generate UUID for the token
        local uuid=$(uuidgen)

        if [[ $(is_empty $line) == 'true' ]]; then
            continue
        fi

        if [[ $(is_ignorable $line) == 'true' ]]; then
            continue
        fi

        # add_lock_storage_token $CYCLE_TEMP_STORAGE_DECL_KEY $uuid

        echo $line
    done < $FILE

    echo $(map_keys $LOCK_STORAGE_DECL_KEY)
}

validate $1
main $1