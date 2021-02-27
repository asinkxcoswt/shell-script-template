#!/bin/bash

############################
# Author: Asinkxcoswt
############################

ex_happy() {
    _doc '
        Test happy case
    ' && return 1

    echo "I am happy"
}

ex_unhappy() {
    _doc '
        Test the "error" command
    ' && return 1

    echo "Sad" && error "I am not happy"
}

ex_success_or_failure() {
    _doc '
        This example show you the error handling behavior.\n
        You can use || and && to handle in case your command fails.\n
        If a command in a pipe fails, all the pipe also fails
    ' && return 1

    echo "success" | grep "success" && { 
        alert "I am success" 
    } || { 
        error "I am failed" 
    }

    echo "success" | grep "failure" | echo "Hahaha the pipe will fail because grep fail" && { 
        alert "I am success" 
    } || { 
        error "I am failed" 
    }
}

ex_oops() {
    _doc '
        What will happens when there is an error that your forgot to handle with && and ||
    ' && return 1

    echo "Invalid command? $(some_invalid_command)"
}

_private_command() {
    echo "I am private"
}

ex_public_command() {
    _doc "
        All function that starts with _ will now be listed and cannot be invoked externally.\n
        But you can still invoke the function inside the script itself.
    " && return 1

    alert "I am going to call _private_command"

    _private_command
}

# shellcheck disable=SC1091
source template.sh