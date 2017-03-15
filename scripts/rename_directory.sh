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
    usage
fi
    
if [[ -z "${HTTP_PORT}" ]] 
then
    echo >&2 "Missing arguments."
    usage
fi
    
if [[ ! -d "${REPO_DIRECTORY}" ]] 
then
    echo >&2 "Invalid directory specified: ${REPO_DIRECTORY}."
    usage
fi
    
# Unless we run the singularity image with --writable,
# these changes will not persist between invocatoins
for file in "/srv/ga4gh/application.wsgi" "/srv/ga4gh/config.py" "/etc/apache2/sites-available/000-default.conf"
do
    sed -i -e "s/@@DIRECTORY@@/${REPO_DIRECTORY}/" "${file}"
done

for file in "/etc/apache2/ports.conf"
do
    sed -i -e "s/@@HTTPPORT@@/${HTTP_PORT}/" "${file}"
done
