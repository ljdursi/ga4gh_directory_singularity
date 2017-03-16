#!/bin/bash

readonly COMMAND=$1
readonly EXECUTABLE_PATH=${USE_EXECUTABLE_PATH:-"/usr/local/bin"}

function usage {
    echo >&2 "$0: execute a command from the docker. "
    echo >&2 "    options: "
    echo >&2 "       init /path/to/reference.fa /path/to/data/directory : initializes a repo in a data directory"
    echo >&2 "       serve /path/to/directory/containing/repo http_port : serves the repo"
    exit 1
}

###
### Make sure options are valid 
###
if [[ -z "${COMMAND}" ]] 
then
    echo >&2 "Missing arguments."
    usage
fi

case $COMMAND in
    "init") 
        "${EXECUTABLE_PATH}/create_repo.sh" "${@:2}"
        ;;
    "serve")
        "${EXECUTABLE_PATH}/rename_directory.sh" "$2" "$3"
        exec apachectl -DFOREGROUND "${@:4}"
        ;;
    *)
        >&2 echo "Invalid command: $COMMAND"
        usage
        ;;
esac
