#!/bin/bash
readonly REPO_DIRECTORY=$1
readonly HTTP_PORT=$2
readonly EXECUTABLE_PATH=${USE_EXECUTABLE_PATH:-"/usr/local/bin"}

function usage {
    echo >&2 "$0 /path/to/repo/directory http_port : configure directory to run the server. "
    exit 1
}

if [[ -z "${REPO_DIRECTORY}" ]] 
then
    echo >&2 "Missing arguments."
    echo >&2 "Invoked as: $*"
    usage
fi
    
if [[ -z "${HTTP_PORT}" ]] 
then
    echo >&2 "Missing arguments."
    echo >&2 "Invoked as: $*"
    usage
fi
    
if [[ ! -d "${REPO_DIRECTORY}" ]] 
then
    echo >&2 "Invalid directory specified: ${REPO_DIRECTORY}."
    usage
fi
    
# Unless we run the singularity image with --writable,
# these changes will not persist between invocatoins
for file in "/srv/ga4gh/application.wsgi" "/srv/ga4gh/config.py" "/etc/apache2/sites-enabled/000-default.conf" "/etc/apache2/ports.conf" "/etc/apache2/envvars"
do
    sed -e "s#@@DIRECTORY@@#${REPO_DIRECTORY}#" -e "s/@@HTTPPORT@@/${HTTP_PORT}/" "${file}".tmpl > "${file}"
done
