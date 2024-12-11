#!/bin/bash

#-----Códigos ANSI para cores no terminal-------

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
    echo -e "${GREEN}[OK]${TAB}${NC}$1${NC}"
}

MsgWarn() {
    echo -e "${YELLOW}[WARN]${TAB}${NC}$1${NC}"
}

MsgError() {
    echo -e "${RED}[ERROR]${TAB}${NC}$1${NC}"
}

readYNInput() {
    while true; do
        echo -ne "${BOLD}$1${NB}:(y/n) "
        read -n 1 -r answer
        case "$answer" in
        [YySs])
            echo
            return 0
            ;;
        [Nn])
            echo
            return 1
            ;;
        *) echo -e "\nInvalid input. Please try again." ;;
        esac
    done
}

boldQuestion() {
    echo -ne "${BOLD}$1:${NB} "
}

readBoldWithSuggestion() {
    answer=""
    while [[ -z "$answer" || ! "$answer" =~ [[:alnum:]] ]]; do
        read -er -i "$1" answer
    done
    echo "$answer"
}

Help() {
    echo
    echo -e "Usage: ${GREEN}./go-work${NC} [OPTIONS]"
    echo -e "Options: ${RED}*${NC} are mandatory parameters"
    echo -e "${TAB}${YELLOW}-s, --start${NC}${TAB}Start the application using all docker profiles"
    echo
    echo -e "${TAB}${YELLOW}--dev-install${NC}${TAB}Install dev dependencies to work on this repository (goose, lefthook)."
    echo
    echo -e "${TAB}${YELLOW}-h, --help${NC}${TAB}Show this help message."
    echo
    exit 0
}

checkDependencies() {
    local isInstalled=()
    local notInstalled=()
    # Check for installed dependencies
    MsgInfo "Checking for installed dependencies..."
    dependencies=("go" "docker")

    for dependency in "${dependencies[@]}"; do
        if command -v "${dependency}" >/dev/null 2>&1; then
            version=$("${dependency}" --version 2>/dev/null || "${dependency}" version 2>/dev/null || echo "Not_found")
            MsgSuccess "${GREEN}${dependency}${NC} is installed (version ${GREEN}${version:0:20}${NC})."
            isInstalled+=(1)
        else
            isInstalled+=(0)
            notInstalled+=("${dependency}")
            MsgWarn "${YELLOW}${dependency}${NC} is ${YELLOW}not${NC} installed."
        fi
    done
    for dep in "${isInstalled[@]}"; do
        if [[ "$dep" != 1 ]]; then
            MsgError "This dependencies are required: ${RED}${notInstalled[*]}${NC}. Install them and then run this script again."
            exit 1
        fi
    done
    echo
}

DevInstall() {
    checkDependencies

    declare -A devDepUrls=(
        ["goose"]="github.com/pressly/goose/v3/cmd/goose@latest"
        ["lefthook"]="github.com/evilmartians/lefthook@latest"
    )

    local notInstalled=()
    # Check for installed dependencies
    MsgInfo "Checking for installed dev-dependencies..."
    dependencies=("goose" "lefthook")

    for dependency in "${dependencies[@]}"; do
        if command -v "${dependency}" >/dev/null 2>&1; then
            version=$("${dependency}" --version 2>/dev/null || "${dependency}" version 2>/dev/null || echo "Not_found")
            MsgSuccess "${GREEN}${dependency}${NC} is installed (version ${GREEN}${version:0:20}${NC})."
        else
            notInstalled+=("${dependency}")
            MsgWarn "${YELLOW}${dependency}${NC} is ${YELLOW}not${NC} installed."

        fi
    done

    if ! readYNInput "Would you like to install all missing dev-dependencies now?"; then
        MsgWarn "Aborted by the user"
        exit 0
    fi
    for devDep in "${notInstalled[@]}"; do
        if [[ -z "${devDepUrls[$devDep]}" ]]; then
            MsgError "Missing dependency ($devDep) url"
            exit 1
        fi
        MsgInfo "Installing $devDep from ${devDepUrls[$devDep]}"
        go install "${devDepUrls[$devDep]}"
    done
}

Start() {
    docker compose --profile "*" up
}
