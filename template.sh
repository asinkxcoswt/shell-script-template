#!/bin/bash

############################
# Author: Asinkxcoswt
############################

_doc() {
  if [ -z "${X_DOC}" ]; then
    return 1
  fi

  echo $* && return 0
}

alert() {
  _doc 'To print a normal message with a cute cow.' && return 1
  if [ -n "${X_SILENT}" ]; then
    return 0
  fi  

  echo ""
  echo " ______________________
 < $* >
 ----------------------
        \   ^__^
         \  (..)\_______
            (__)\       )\/
                ||----w |
                ||     ||"
  echo ""
}

error() {
  _doc 'To print an error message with a cute cow, and then exit the script with non-zero exit code'  && return 1
  echo ""
  echo " ______________________
  < $* >
 ----------------------
        \   ^__^
         \  (xx)\_______
            (__)\       )\/
             U  ||----w |
                ||     ||" 1>&2

  echo ""
  exit 1
}

all_commands() {
    _doc 'Show all available commands'  && return 1
    declare -F | awk '{print $3}' | grep -vE '^_'
}

help() {
    _doc 'Show all available commands and their documentation' && return 1
    for command in $(all_commands); do
        printf "$command\n$(X_DOC=true $command | sed 's/^ */\t/g')\n\n"
    done
}

set -eo pipefail

command="$1"
test -z "${command}" && { help; exit 1; }

all_commands | grep "${command}" > /dev/null || error "Unknown command: ${command}"

shift 1
# shellcheck disable=SC2048,SC2086,SC2068
${command} $@