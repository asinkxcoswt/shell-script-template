#!/bin/bash

############################
# Author: Asinkxcoswt
# Download From: https://github.com/asinkxcoswt/shell-script-template
############################

_doc() {
  if [ -z "${X_DOC}" ]; then
    return 1
  fi

  echo $* && return 0
}

mawsay() {
  _doc 'cat say' && return 1
  echo ""
  echo "-----------------------------------"
  printf "$*\n" | fold -w 35 -s
  echo "-----------------------------------"
  echo "
     \   /\_/\  /\\
      \ / o o \ \ \\
       /   Y   \/ /
      /         \/
      \ | | | | /
       '|_|-|_|'   mawsay"  
  
  echo ""
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

encrypt_all() {
    _doc 'Encrypt all secret files (starting with secret.*)' && return 1
    find . -type f -name "secret.*" | while read file
    do
        encrypt "${file}"
    done
}

decrypt_all() {
    _doc 'Decrypt all cypher files (starting with cypher.*)' && return 1
    find . -type f -name "cypher.*" | while read file
    do
        decrypt "${file}"
    done 
}

encrypt() {
    _doc 'Encrypt the input secret_file' && return 1
    local secret_file="$1"
    echo "Begin encrypting file ${secret_file}"

    test -n "${secret_file}" || error "Missing 1st parameter for the secret_file to be encrypted"
    test -f "${secret_file}" || error "The input secret_file ${secret_file} does not exist"
    basename "${secret_file}" | grep -E "^secret." || error "The input file should have name starting with 'secret.'"
    test -f "./key.bin" || error "Missing the cypher key ./key.bin"

    local out_file="$(echo ${secret_file} | sed 's/secret\.\(.*\)$/cypher.\1/')"

    openssl enc -aes-256-cbc -pass file:./key.bin -in "${secret_file}" -out "${out_file}" -salt
}

decrypt() {
    _doc 'Decrypt the input cypher_file' && return 1
    local cypher_file="$1"
    echo "Begin decrypting file ${cypher_file}"

    test -n "${cypher_file}" || error "Missing 1st parameter for the cypher_file to be decrypted"
    test -f "${cypher_file}" || error "The input cypher_file ${cypher_file} does not exist"
    basename "${cypher_file}" | grep -E "^cypher." || error "The input file should have name starting with 'cypher.'"
    test -f "./key.bin" || error "Missing the cypher key ./key.bin"

    local out_file="$(echo ${cypher_file} | sed 's/cypher\.\(.*\)$/secret.\1/')"

    openssl enc -d -aes-256-cbc -pass file:./key.bin -in "${cypher_file}" -out "${out_file}"
}

gen_key() {
    _doc 'Generate the cypher key for encryption/decryption' && return 1
    openssl rand -hex 64 -out key.bin
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

all_commands | grep -- "${command}" > /dev/null || error "Unknown command: ${command}"

shift 1
# shellcheck disable=SC2048,SC2086,SC2068
${command} $@
