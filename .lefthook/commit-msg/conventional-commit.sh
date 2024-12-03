#!/bin/bash
# ref https://github.com/joaobsjunior/sh-conventional-commits/blob/main/commit-msg

export TAB='\t'
export X2TAB='\t\t'
export X3TAB='\t\t\t'
export RED='\033[0;31m'    #error
export CYAN='\033[0;36m'   #info
export GREEN='\033[0;32m'  #success
export YELLOW='\033[1;33m' #warn
export BOLD='\e[1m'        # Bold text
export NB='\e[0m'          # Remove bold
export NC='\033[0m'
export SHELL_NAME=${SHELL##*\/}
export SHELL_CONFIG=""

echo -e "${NC}" &>/dev/null

#-----Funções para padronizar mensagens-------

MsgInfo() {
    echo -e "${CYAN}[INFO]${TAB}${NC}$1${NC}"
}

MsgSuccess() {
    echo -e "${GREEN}[SUCCESS]${TAB}${NC}$1${NC}"
}

MsgWarn() {
    echo -e "${YELLOW}[WARN]${TAB}${NC}$1${NC}"
}

MsgError() {
    echo -e "${RED}[ERROR]${TAB}${NC}$1${NC}"
}

if [[ -z $1 ]]; then
    MsgError "Failed to retrieve commit message file"
fi

REGEX="^((Merge[ a-z-]* branch.*)|(Revert*)|((build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\(.*\))?!?: .*))"

FILE=$1
START_LINE=$(head -n1 "$FILE")

if ! [[ $START_LINE =~ $REGEX ]]; then
    MsgError "Commit aborted for not following the Conventional Commit standard.​"
    exit 1
else
    MsgSuccess "Valid commit message."
fi
