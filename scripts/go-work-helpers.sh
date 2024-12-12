#!/bin/bash

unamestr=$(uname)
if [ "$unamestr" = 'Linux' ]; then

    # shellcheck disable=SC2046
    export $(grep -v '^#' .env | xargs -d '\n')

elif [ "$unamestr" = 'FreeBSD' ] || [ "$unamestr" = 'Darwin' ]; then

    # shellcheck disable=SC2046
    export $(grep -v '^#' .env | xargs -0)

fi

export GOOSE_DRIVER=postgres
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
    echo -e "${TAB}${YELLOW}-m, --migration${NC} ${RED}[options]${NC}${TAB}Manage migrations using goose"
    echo -e "${X3TAB}${RED}create <name>*${NC}${TAB}Create a new migration"
    echo -e "${X3TAB}${RED}up${NC}${X2TAB}Run migrations up to the last"
    echo -e "${X3TAB}${RED}down${NC}${X2TAB}Rollback the last migration"
    echo -e "${X3TAB}${RED}reset${NC}${X2TAB}Rollback all migrations"
    echo -e "${X3TAB}${RED}fix${NC}${X2TAB}Apply sequential ordering to migrations"
    echo -e "${X3TAB}${RED}validate${NC}${TAB}Check migration files without running them"
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

Migrations() {
    acceptedArgs=("create" "up" "down" "reset" "fix" "validate" "status")
    currDir="$PWD"
    export GOOSE_MIGRATION_DIR="$currDir/.database/migrations"

    if [[ -z "$POSTGRES_USER" ]] || [[ -z "$POSTGRES_DB" ]] || [[ -z "$POSTGRES_PASSWORD" ]]; then
        MsgError "Invalid .env file. It should contain the following variables: ${RED}POSTGRES_USER, POSTGRES_DB${NC} and ${RED}POSTGRES_PASSWORD${NC}"
        exit 1
    fi
    export GOOSE_DBSTRING="user=$POSTGRES_USER dbname=$POSTGRES_DB sslmode=disable"

    if [[ -z "$1" || ! " ${acceptedArgs[*]} " =~ $1 ]]; then
        MsgError "Invalid or missing argument for migrations. Accepted arguments are: ${RED}${acceptedArgs[*]}${NC}"
        exit 1
    fi

    case "${1}" in
    create)
        if [[ -z "$2" ]]; then
            MsgError "You should input a name for the new migration."
            exit 1
        fi
        goose create "$2" go
        ;;
    up) goose up ;;
    down) goose down ;;
    reset) goose reset ;;
    fix) goose fix ;;
    validate) goose validate ;;
    status) goose status ;;
    esac
}
