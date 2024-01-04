#!/bin/bash

# Constants, which represent pre-defined regexp to analyse
# C code.
readonly FUNCTION_REGEXP_DECL_KEY='^[a-z]+ ([a-z]+)\(\) \{$'
readonly RETURN_REGEXP_DECL_KEY=''
readonly PRINT_REGEXP_DECL_KEY=''
readonly INCLUDE_REGEXP_DECL_KEY='(^#include <[a-z]+(\.h)?>)|(#include "[a-z]+(\.h)?")$'
readonly FOR_CYCLE_REGEXP_DECL_KEY='^for \([a-z]+ [a-z]+ = [0-9]+\; [a-z]+ \< [0-9]+\; [a-z]+\+\+\) \{$'


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

# Describes storage related properties.
readonly LOCK_STORAGE_DECL_KEY='lock_storage'
readonly CYCLE_LOCK_STORAGE_DECL_KEY='cycle'

readonly SCOPE_STORAGE_DECL_KEY='scope'
readonly INDEX_SCOPE_STORAGE_DECL_KEY='index'

readonly REGEXP_MATCH_STORAGE_DECL_KEY='regexp_storage'
readonly LAST_REGEXP_MATCH_DECL_KEY='last'

# # Describes pointers for the output file.
# PREVIOUS_OUTPUT_POINTER=0
# CURRENT_OUTPUT_POINTER=0

# Describes amount of spaces, which should be applied
# for each scope index number increase.
readonly SCOPE_INDEX_SHIFT=4

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

function set_last_regexp_match() {
    map_put $REGEXP_MATCH_STORAGE_DECL_KEY $LAST_REGEXP_MATCH_DECL_KEY $1
}

function retrieve_last_regexp_match() {
    echo $(map_get $REGEXP_MATCH_STORAGE_DECL_KEY $LAST_REGEXP_MATCH_DECL_KEY)
}



function increase_index_scope() {
    local value=$(map_get $SCOPE_STORAGE_DECL_KEY $INDEX_SCOPE_STORAGE_DECL_KEY)
    map_put $SCOPE_STORAGE_DECL_KEY $INDEX_SCOPE_STORAGE_DECL_KEY $(( ++value ))
}

function decrease_index_scope() {
    local value=$(map_get $SCOPE_STORAGE_DECL_KEY $INDEX_SCOPE_STORAGE_DECL_KEY)
    map_put $SCOPE_STORAGE_DECL_KEY $INDEX_SCOPE_STORAGE_DECL_KEY $(( --value ))
}

function retrieve_index_scope() {
    echo $(map_get $SCOPE_STORAGE_DECL_KEY $INDEX_SCOPE_STORAGE_DECL_KEY)
}

function init_storage() {
    map_put $SCOPE_STORAGE_DECL_KEY $INDEX_SCOPE_STORAGE_DECL_KEY 0
}


# Validates given file to be processed.
function validate() {
    if [[ -z $1 ]]; then
        echo "Input file name was not provided"
        exit 1
    fi

    if [[ $1 != *.c ]]; then
        echo "$1 does not have required *.c extension"
        exit 1
    fi

    if [[ ! -f "$1" ]]; then
        echo "$1 does not exist"
        exit 1
    fi

    if [[ -z $2 ]]; then
        echo "Output file name was not provided"
        exit 1
    fi

    if [[ $2 != *.sh ]]; then
        echo "$2 does not have required *.sh extension"
        exit 1
    fi

    gcc -fsyntax-only $1
    if [ ! $? -eq 0 ]; then
        exit 1
    fi

    > $2
}

# Checks if the given line is empty.
function is_empty() {
    if [ -z "$1" ]; then
        return 0
    else 
        return 1
    fi
}

# Checks if the given line is ignorable.
function is_ignorable() {
    if [[ $1 =~ $INCLUDE_REGEXP_DECL_KEY ]]; then
        return 0
    else    
        return 1
    fi
}

# Checks if the given line is a function beginning declaration.
function is_function_beginning() {
    if [[ $1 =~ $FUNCTION_REGEXP_DECL_KEY ]]; then
        set_last_regexp_match "${BASH_REMATCH[1]}"
        # map_put $REGEXP_MATCH_STORAGE_DECL_KEY $LAST_REGEXP_MATCH_DECL_KEY "${BASH_REMATCH[1]}"
        return 0
    else    
        return 1
    fi
}

# Checks if the given line is a for cycle declaration.
function is_for_cycle() {
    if [[ $1 =~ $FOR_CYCLE_REGEXP_DECL_KEY ]]; then
        return 0
    else    
        return 1
    fi
}

# # Adds given token to a selected lock storage cell. 
# # The first argument is a lock storage type.
# # The second argument is a token ID.
# function add_lock_storage_token() {
#     map_put $LOCK_STORAGE_DECL_KEY $1 $2
# }

# function increase_lock_number() {
#     map_put $LOCK_STORAGE_DECL_KEY $1 $2
# }

# # Finds available pointer position at the output file.
# function find_available_position() {

# }
# 
function retrieve_shift() {
    local shift=""
    for ((i=0;i<retrieve_index_scope;i++)); do
        for ((g=1;g<=SCOPE_INDEX_SHIFT;g++)); do
            shift+=" "
        done
    done
    
    echo "$shift"
}


function compose_function_beginning() {
    echo "$(retrieve_shift)$FUNCTION_RESERVED_KEY $1() $LEFT_BRACKET_RESERVED_KEY"
}

function compose_function_ending() {
    echo "$(retrieve_shift)${$RIGHT_BRACKET_RESERVED_KEY}"
}


# Writes given content to the output file.
function write_to_output() {
    echo "$1" >> $2
}   

# Main entrypoint for the transpilator.
function main() {
    while read -r line || [ -n "$line" ]
    do
        # Generate UUID for the token
        local uuid=$(uuidgen)

        is_empty "$line"
        if [[ $? == 0 ]]; then
            continue
        fi

        is_ignorable "$line"
        if [[ $? == 0 ]]; then
            continue
        fi

        is_function_beginning "$line"
        if [[ $? == 0 ]]; then
            write_to_output "$(compose_function_beginning $(retrieve_last_regexp_match))" $2
            increase_index_scope
            continue
        fi

        is_for_cycle "$line"
        if [[ $? == 0 ]]; then
            increase_index_scope
            continue
        fi

        # add_lock_storage_token $CYCLE_TEMP_STORAGE_DECL_KEY $uuid

        echo "$line"
    done < $1

    # echo $(map_keys $LOCK_STORAGE_DECL_KEY)
}

validate $1 $2
init_storage
main $1 $2