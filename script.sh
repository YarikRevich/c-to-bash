#!/bin/bash

# Describes regexp used for input file analization.
readonly FUNCTION_DECLARATION_REGEXP_DECL_KEY='^[a-z]+ ([a-z]+)\(\)( )?\{$'
readonly FUNCTION_CALL_REGEXP_DECL_KEY='^([a-zA-Z]+)\(\)$'
readonly FUNCTION_RETURN_REGEXP_DECL_KEY='^return( )?(\"(((\-)?[a-zA-Z0-9]+)\")|((\-)?[a-zA-Z0-9]+))\;$'
readonly VARIABLE_REGEXP_DECL_KEY='^[a-zA-Z]+ ([a-zA-Z]+)( )?=( )?([a-zA-Z0-9 ]+)\;$'
readonly PRINT_REGEXP_DECL_KEY='^printf\("([a-zA-Z0-9 ]+)"\)\;$'
readonly INCLUDE_REGEXP_DECL_KEY='(^#include( )?<[a-z]+(\.h)?>)|(#include "[a-z]+(\.h)?")$'
readonly IF_CONDITION_REGEXP_DECL_KEY='^if( )?\(([a-zA-Z0-9]+)( )?(==|!=|<|<=|>|>=)( )?([a-zA-Z0-9]+)\)( )?\{$'
readonly FOR_CYCLE_REGEXP_DECL_KEY='^for( )?\([a-zA-Z0-9]+ ([a-zA-Z0-9]+)( )?=( )?([a-zA-Z0-9]+)\;( )?[a-zA-Z0-9]+( )?(<|>|>=|<|<=)( )?([a-zA-Z0-9]+)\;( )?((([a-zA-Z0-9]+\+\+)\))|(([a-zA-Z0-9]+\-\-)\))|((\-\-[a-zA-Z0-9]+)\))|((\+\+[a-zA-Z0-9]+)\)))( )?\{$'
readonly COMMENT_DECL_KEY='^\/\/([a-zA-Z0-9\. ]+)$'

# Describes input code reserved keys, used for output composition.
readonly IF_RESERVED_KEY='if'
readonly FI_RESERVED_KEY='fi'
readonly ELSE_RESERVED_KEY='else'
readonly FOR_RESERVED_KEY='for'
readonly WHILE_RESERVED_KEY='while'
readonly THEN_RESERVED_KEY='then'
readonly DO_RESERVED_KEY='do'
readonly RETURN_RESERVED_KEY='return'
readonly BREAK_RESERVED_KEY='break'
readonly CONTINUE_RESERVED_KEY='continue'
readonly DONE_RESERVED_KEY='done'
readonly FUNCTION_RESERVED_KEY='function'
readonly LOCAL_RESERVED_KEY='local'
readonly RIGHT_BRACKET_RESERVED_KEY='}'
readonly LEFT_BRACKET_RESERVED_KEY='{'
readonly RIGHT_CURVED_BRACKET_RESERVED_KEY=')'
readonly LEFT_CURVED_BRACKET_RESERVED_KEY='('
readonly RIGHT_CUBIC_BRACKET_RESERVED_KEY=']'
readonly LEFT_CUBIC_BRACKET_RESERVED_KEY='['
readonly EQUAL_RESERVED_KEY='='
readonly COLON_RESERVED_KEY=';'
readonly DOLLAR_SIGN_RESERVED_KEY='$'
readonly COMMENT_RESERVED_KEY='#'
readonly SHEBANG_RESERVED_KEY='#!'

# Describes all supported commands.
readonly ECHO_COMMAND='echo'

# Describes name of the entrypoint function.
readonly ENTRYPOINT_FUNCTION_RESERVED_KEY='main'

# Describes scope storage related properties.
readonly SCOPE_STORAGE_DECL_KEY='scope'
readonly FUNCTION_SCOPE_DECL_KEY='function'
readonly CYCLE_SCOPE_DECL_KEY='cycle'
readonly IF_SCOPE_DECL_KEY='if'
readonly INDEX_SCOPE_STORAGE_DECL_KEY='index'

# Describes regexp storage related properties.
readonly REGEXP_MATCH_STORAGE_DECL_KEY='regexp'
readonly FIRST_REGEXP_MATCH_DECL_KEY='first'
readonly SECOND_REGEXP_MATCH_DECL_KEY='second'
readonly THIRD_REGEXP_MATCH_DECL_KEY='third'
readonly FORTH_REGEXP_MATCH_DECL_KEY='forth'
readonly FIFTH_REGEXP_MATCH_DECL_KEY='fifth'

# Describes shell related properties.
readonly DEFAULT_SHEBANG='/bin/bash'

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

# Checks if the given key exists in a global map.
function map_exists() {
    for key in $(map_keys $1); do
        if [[ $(map_get $1 $key) == $2 ]]; then
            return 0
        fi
    done

    return 1
}
 
# Sets first regexp match.
function set_first_regexp_match() {
    map_put $REGEXP_MATCH_STORAGE_DECL_KEY $FIRST_REGEXP_MATCH_DECL_KEY "$1"
}

# Retrieves first regexp match.
function retrieve_first_regexp_match() {
    echo "$(map_get $REGEXP_MATCH_STORAGE_DECL_KEY $FIRST_REGEXP_MATCH_DECL_KEY)"
}

# Sets second regexp match.
function set_second_regexp_match() {
    map_put $REGEXP_MATCH_STORAGE_DECL_KEY $SECOND_REGEXP_MATCH_DECL_KEY "$1"
}

# Retrieves second regexp match.
function retrieve_second_regexp_match() {
    echo "$(map_get $REGEXP_MATCH_STORAGE_DECL_KEY $SECOND_REGEXP_MATCH_DECL_KEY)"
}

# Sets third regexp match.
function set_third_regexp_match() {
    map_put $REGEXP_MATCH_STORAGE_DECL_KEY $THIRD_REGEXP_MATCH_DECL_KEY "$1"
}

# Retrieves third regexp match.
function retrieve_third_regexp_match() {
    echo "$(map_get $REGEXP_MATCH_STORAGE_DECL_KEY $THIRD_REGEXP_MATCH_DECL_KEY)"
}

# Sets forth regexp match.
function set_forth_regexp_match() {
    map_put $REGEXP_MATCH_STORAGE_DECL_KEY $FORTH_REGEXP_MATCH_DECL_KEY "$1"
}

# Retrieves forth regexp match.
function retrieve_forth_regexp_match() {
    echo "$(map_get $REGEXP_MATCH_STORAGE_DECL_KEY $FORTH_REGEXP_MATCH_DECL_KEY)"
}

# Sets fifth regexp match.
function set_fifth_regexp_match() {
    map_put $REGEXP_MATCH_STORAGE_DECL_KEY $FIFTH_REGEXP_MATCH_DECL_KEY "$1"
}

# Retrieves fifth regexp match.
function retrieve_fifth_regexp_match() {
    echo "$(map_get $REGEXP_MATCH_STORAGE_DECL_KEY $FIFTH_REGEXP_MATCH_DECL_KEY)"
}

# Increases if scope value.
function increase_if_scope() {
    local value=$(map_get $SCOPE_STORAGE_DECL_KEY $IF_SCOPE_DECL_KEY)
    map_put $SCOPE_STORAGE_DECL_KEY $IF_SCOPE_DECL_KEY $(( ++value ))
}

# Decreases if scope value.
function decrease_if_scope() {
    local value=$(map_get $SCOPE_STORAGE_DECL_KEY $IF_SCOPE_DECL_KEY)
    map_put $SCOPE_STORAGE_DECL_KEY $IF_SCOPE_DECL_KEY $(( --value ))
}

# Retrieves if scope value.
function retrieve_if_scope() {
    echo "$(map_get $SCOPE_STORAGE_DECL_KEY $IF_SCOPE_DECL_KEY)"
}

function increase_cycle_scope() {
    local value=$(map_get $SCOPE_STORAGE_DECL_KEY $CYCLE_SCOPE_DECL_KEY)
    map_put $SCOPE_STORAGE_DECL_KEY $CYCLE_SCOPE_DECL_KEY $(( ++value ))
}

function decrease_cycle_scope() {
    local value=$(map_get $SCOPE_STORAGE_DECL_KEY $CYCLE_SCOPE_DECL_KEY)
    map_put $SCOPE_STORAGE_DECL_KEY $CYCLE_SCOPE_DECL_KEY $(( --value ))
}

function retrieve_cycle_scope() {
    echo "$(map_get $SCOPE_STORAGE_DECL_KEY $CYCLE_SCOPE_DECL_KEY)"
}

function enable_function_scope() {
    map_put $SCOPE_STORAGE_DECL_KEY $FUNCTION_SCOPE_DECL_KEY 1
}

function disable_function_scope() {
    map_put $SCOPE_STORAGE_DECL_KEY $FUNCTION_SCOPE_DECL_KEY 0
}

function retrieve_function_scope() {
    echo "$(map_get $SCOPE_STORAGE_DECL_KEY $FUNCTION_SCOPE_DECL_KEY)"
}

function increase_index_scope() {
    local value=$(map_get $SCOPE_STORAGE_DECL_KEY $INDEX_SCOPE_STORAGE_DECL_KEY)
    map_put $SCOPE_STORAGE_DECL_KEY $INDEX_SCOPE_STORAGE_DECL_KEY $(( ++value ))
}

# Decreases shift index from scope storage.
function decrease_index_scope() {
    local value=$(map_get $SCOPE_STORAGE_DECL_KEY $INDEX_SCOPE_STORAGE_DECL_KEY)
    map_put $SCOPE_STORAGE_DECL_KEY $INDEX_SCOPE_STORAGE_DECL_KEY $(( --value ))
}

# Retrieves shift index from the scope storage.
function retrieve_index_scope() {
    echo "$(map_get $SCOPE_STORAGE_DECL_KEY $INDEX_SCOPE_STORAGE_DECL_KEY)"
}

# Initializes internal storage.
function init_storage() {
    map_put $SCOPE_STORAGE_DECL_KEY $INDEX_SCOPE_STORAGE_DECL_KEY 0
    map_put $SCOPE_STORAGE_DECL_KEY $IF_SCOPE_DECL_KEY 0
    map_put $SCOPE_STORAGE_DECL_KEY $CYCLE_SCOPE_DECL_KEY 0
    map_put $SCOPE_STORAGE_DECL_KEY $FUNCTION_SCOPE_DECL_KEY 0
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
    if [[ $1 =~ $FUNCTION_DECLARATION_REGEXP_DECL_KEY ]]; then
        set_first_regexp_match "${BASH_REMATCH[1]}"
        return 0
    else    
        return 1
    fi
}

# Checks if the given line is a function call declaration.
function is_function_call() {
    if [[ $1 =~ $FUNCTION_CALL_REGEXP_DECL_KEY ]]; then
        set_first_regexp_match "${BASH_REMATCH[1]}"
        return 0
    else    
        return 1
    fi
}

# Checks if the given line is a function return declaration.
function is_function_return() {
    if [[ $1 =~ $FUNCTION_RETURN_REGEXP_DECL_KEY ]]; then
        set_first_regexp_match "${BASH_REMATCH[2]}"
        return 0
    else    
        return 1
    fi
}

function is_variable() {
    if [[ $1 =~ $VARIABLE_REGEXP_DECL_KEY ]]; then
        set_first_regexp_match "${BASH_REMATCH[1]}"
        set_second_regexp_match "${BASH_REMATCH[4]}"
        return 0
    else    
        return 1
    fi
}

function is_ending_bracket() {
    if [[ $1 =~ $RIGHT_BRACKET_RESERVED_KEY ]]; then
        return 0
    else    
        return 1
    fi
}

function is_printf() {
    if [[ $1 =~ $PRINT_REGEXP_DECL_KEY ]]; then
        set_first_regexp_match "${BASH_REMATCH[1]}"
        return 0
    else    
        return 1
    fi
}

function is_if_condition() {
    if [[ $1 =~ $IF_CONDITION_REGEXP_DECL_KEY ]]; then
        set_first_regexp_match "${BASH_REMATCH[2]}"
        set_second_regexp_match "${BASH_REMATCH[4]}"
        set_third_regexp_match "${BASH_REMATCH[6]}"
        return 0
    else    
        return 1
    fi
}

# Checks if the given line is a for cycle declaration.
function is_for_cycle() {
    if [[ $1 =~ $FOR_CYCLE_REGEXP_DECL_KEY ]]; then
        set_first_regexp_match "${BASH_REMATCH[2]}"
        set_second_regexp_match "${BASH_REMATCH[5]}"
        set_third_regexp_match "${BASH_REMATCH[8]}"
        set_forth_regexp_match "${BASH_REMATCH[10]}"
        set_fifth_regexp_match "${BASH_REMATCH[14]}"
        return 0
    else    
        return 1
    fi
}

function is_break() {
    if [[ $1 =~ $BREAK_RESERVED_KEY ]]; then
        return 0
    else    
        return 1
    fi
}

function is_continue() {
    if [[ $1 =~ $CONTINUE_RESERVED_KEY ]]; then
        return 0
    else    
        return 1
    fi
}

function is_comment() {
    if [[ $1 =~ $COMMENT_DECL_KEY ]]; then
        set_first_regexp_match "${BASH_REMATCH[1]}" 
        return 0
    else    
        return 1
    fi
}

# Generates local shift due to the previously saved state.
function retrieve_shift() {
    local shift=""
    for ((i=0;i<$(retrieve_index_scope);i++)); do
        for ((g=1;g<=SCOPE_INDEX_SHIFT;g++)); do
            shift+=" "
        done
    done
    
    echo "$shift"
}

function compose_function_beginning() {
    echo "$(retrieve_shift)$FUNCTION_RESERVED_KEY $1$LEFT_CURVED_BRACKET_RESERVED_KEY$RIGHT_CURVED_BRACKET_RESERVED_KEY $LEFT_BRACKET_RESERVED_KEY"
}

function compose_function_call() {
    echo "$(retrieve_shift) $1"
}

function compose_function_return() {
    echo "$(retrieve_shift)$ECHO_COMMAND $1"
}

function compose_local_variable() {
    echo "$(retrieve_shift)$LOCAL_RESERVED_KEY $1$EQUAL_RESERVED_KEY$2
    "
}

function compose_global_variable() {
    echo "$(retrieve_shift)$1$EQUAL_RESERVED_KEY$2
    "
}

function compose_if_condition() {   
    echo "$(retrieve_shift)$IF_RESERVED_KEY $LEFT_CUBIC_BRACKET_RESERVED_KEY$LEFT_CUBIC_BRACKET_RESERVED_KEY $DOLLAR_SIGN_RESERVED_KEY$LEFT_CURVED_BRACKET_RESERVED_KEY$LEFT_CURVED_BRACKET_RESERVED_KEY $1 $RIGHT_CURVED_BRACKET_RESERVED_KEY$RIGHT_CURVED_BRACKET_RESERVED_KEY $2 $DOLLAR_SIGN_RESERVED_KEY$LEFT_CURVED_BRACKET_RESERVED_KEY$LEFT_CURVED_BRACKET_RESERVED_KEY $3 $RIGHT_CURVED_BRACKET_RESERVED_KEY$RIGHT_CURVED_BRACKET_RESERVED_KEY $RIGHT_CUBIC_BRACKET_RESERVED_KEY$RIGHT_CUBIC_BRACKET_RESERVED_KEY$COLON_RESERVED_KEY $THEN_RESERVED_KEY"
}

function compose_if_ending() {
    echo "$(retrieve_shift)$FI_RESERVED_KEY
    "
}

function compose_for_cycle_beginning() {
    echo "$(retrieve_shift)$FOR_RESERVED_KEY $LEFT_CURVED_BRACKET_RESERVED_KEY$LEFT_CURVED_BRACKET_RESERVED_KEY $1$EQUAL_RESERVED_KEY$2$COLON_RESERVED_KEY $1 $3 $4$COLON_RESERVED_KEY $5 $RIGHT_CURVED_BRACKET_RESERVED_KEY$RIGHT_CURVED_BRACKET_RESERVED_KEY$COLON_RESERVED_KEY $DO_RESERVED_KEY"
}

function compose_cycle_ending() {
    echo "$(retrieve_shift)$DONE_RESERVED_KEY
    "
}

function compose_break() {
    echo "$(retrieve_shift)$BREAK_RESERVED_KEY"
}

function compose_continue() {
    echo "$(retrieve_shift)$CONTINUE_RESERVED_KEY"
}

function compose_printf() {
    echo "$(retrieve_shift)$ECHO_COMMAND \"$1\""
}

function compose_ending_bracket() {
    echo "$(retrieve_shift)$RIGHT_BRACKET_RESERVED_KEY
    "
}

function compose_comment() {
    echo "$(retrieve_shift)$COMMENT_RESERVED_KEY$1"
}

function compose_shebang() {
    echo "$SHEBANG_RESERVED_KEY$DEFAULT_SHEBANG
    "
}

function compose_entrypoint_execution() {
    echo "$ENTRYPOINT_FUNCTION_RESERVED_KEY"
}

# Writes given content to the output file.
function write_to_output() {
    echo "$1" >> $2
}   

# Initiates terminate exit.
function terminate_exit() {
    echo "Unsupported input was detacted!"
    rm $1
    exit 1
}

# Main entrypoint for the transpilator.
function main() {
    write_to_output "$(compose_shebang)" $2

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

        is_variable "$line"
        if [[ $? == 0 ]]; then
            if [[ $(retrieve_function_scope) == 1 ]]; then
                write_to_output "$(compose_local_variable "$(retrieve_first_regexp_match)" "$(retrieve_second_regexp_match)")" $2
            else
                write_to_output "$(compose_global_variable "$(retrieve_first_regexp_match)" "$(retrieve_second_regexp_match)")" $2
            fi
            
            continue
        fi

        is_function_beginning "$line"
        if [[ $? == 0 ]]; then
            write_to_output "$(compose_function_beginning "$(retrieve_first_regexp_match)")" $2
            enable_function_scope
            increase_index_scope
            continue
        fi

        is_function_call "$line"
        if [[ $? == 0 ]]; then
            write_to_output "$(compose_function_call "$(retrieve_first_regexp_match)")" $2
            continue
        fi

        is_function_return "$line"
        if [[ $? == 0 ]]; then
            write_to_output "$(compose_function_return "$(retrieve_first_regexp_match)")" $2
            continue
        fi

        is_if_condition "$line"
        if [[ $? == 0 ]]; then
            write_to_output "$(compose_if_condition "$(retrieve_first_regexp_match)" "$(retrieve_second_regexp_match)" "$(retrieve_third_regexp_match)")" $2
            increase_if_scope
            increase_index_scope
            continue
        fi

        is_for_cycle "$line"
        if [[ $? == 0 ]]; then
            write_to_output "$(compose_for_cycle_beginning "$(retrieve_first_regexp_match)" "$(retrieve_second_regexp_match)" "$(retrieve_third_regexp_match)" "$(retrieve_forth_regexp_match)" "$(retrieve_fifth_regexp_match)")" $2
            increase_cycle_scope
            increase_index_scope
            continue
        fi

        is_break "$line"
        if [[ $? == 0 ]]; then
            write_to_output "$(compose_break)" $2
            continue
        fi

        is_continue "$line"
        if [[ $? == 0 ]]; then
            write_to_output "$(compose_continue)" $2
            continue
        fi

        is_printf "$line"
        if [[ $? == 0 ]]; then
            write_to_output "$(compose_printf "$(retrieve_first_regexp_match)")" $2
            continue
        fi

        is_ending_bracket "$line"
        if [[ $? == 0 ]]; then
            decrease_index_scope

            if [[ $(retrieve_if_scope) > 0 ]]; then
                write_to_output "$(compose_if_ending)" $2
                decrease_if_scope
            elif [[ $(retrieve_cycle_scope) > 0 ]]; then
                write_to_output "$(compose_cycle_ending)" $2
                decrease_cycle_scope
            else
                if [[ $(retrieve_function_scope) == 1 ]]; then
                    disable_function_scope
                fi

                write_to_output "$(compose_ending_bracket)" $2
            fi
            
            continue
        fi

        is_comment "$line"
        if [[ $? == 0 ]]; then
            write_to_output "$(compose_comment "$(retrieve_first_regexp_match)")" $2
            continue
        fi

        terminate_exit $2
    done < $1

    write_to_output "$(compose_entrypoint_execution)" $2
}

validate $1 $2
init_storage
main $1 $2