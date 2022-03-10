#!/bin/bash

DB_USERNAME="${DB_USERNAME:-root}"
DB_PASSWORD="${DB_PASSWORD:-password}"
DB_NAME="${DB_NAME:-locationmanager}"
DB_HOST="${DB_HOST:-host.docker.internal}"
DB_PORT="${DB_PORT:-5432}"
DB_SCHEMA_NAME="${DB_SCHEMA_NAME:-public}"
DB_URL="jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}?currentSchema=${DB_SCHEMA_NAME}&autoReconnect=true&useSSL=false"
CHANGE_LOG_DIRECTORY="${CHANGE_LOG_DIRECTORY}"
CHANGE_LOG_MASTER_FILE="${CHANGE_LOG_MASTER_FILE:-db/changelog/db.changelog-master.xml}"
CHANGE_SET_FILE="${CHANGE_SET_FILE:-db/changelog/db.changelog-0.1.xml}"
CHANGE_SET_ID="${CHANGE_SET_ID:-location-manager-1.0}"
CHANGE_SET_AUTHOR="${CHANGE_SET_AUTHOR:-Zeal}"


BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

function printLog() {
  case "${1}" in
    "d"|"debug"|"D"|"DEBUG") color="${GREEN}"; shift;;
    "i"|"info"|"I"|"INFO") color="${BLUE}"; shift;;
    "e"|"error"|"E"|"ERROR") color="${RED}"; shift;;
    *) color="${GREEN}";;
  esac

  if [[ "${color}" == "${RED}" ]]; then
    echo -e >&2 "${color}$*${NC}";
  else
    echo -e "${color}$*${NC}";
  fi
}
printLog debug ""
printLog debug "* Current Environment Variables:"
printLog debug "* "
printLog debug "* DB_USERNAME: \"${DB_USERNAME}\""
printLog debug "* DB_PASSWORD: \"${DB_PASSWORD}\""
printLog debug "* DB_NAME: \"${DB_NAME}\""
printLog debug "* DB_HOST: \"${DB_HOST}\""
printLog debug "* DB_PORT: \"${DB_PORT}\""
printLog debug "* DB_SCHEMA_NAME: \"${DB_SCHEMA_NAME}\""
printLog debug "* CHANGE_LOG_DIRECTORY: \"${CHANGE_LOG_DIRECTORY}\""
printLog debug "* CHANGE_SET_FILE: \"${CHANGE_SET_FILE}\""
printLog debug "* CHANGE_LOG_MASTER_FILE: \"${CHANGE_LOG_MASTER_FILE}\""
printLog debug "* CHANGE_SET_ID: \"${CHANGE_SET_ID}\""
printLog debug "* CHANGE_SET_AUTHOR: \"${CHANGE_SET_AUTHOR}\""
printLog debug ""

function calculateCheckSum() {

  docker run --rm \
    -v "${CHANGE_LOG_DIRECTORY}":"/liquibase/changelog" \
    liquibase/liquibase \
    --changelog-file="${CHANGE_LOG_MASTER_FILE}" \
    --url="${DB_URL}" \
    --username="${DB_USERNAME}" \
    --password="${DB_PASSWORD}" \
    "${1}" \
    "${CHANGE_SET_FILE}::${CHANGE_SET_ID}::${CHANGE_SET_AUTHOR}"
}

function history() {
  docker run --rm \
    liquibase/liquibase \
    --url="${DB_URL}" \
    --username="${DB_USERNAME}" \
    --password="${DB_PASSWORD}" \
    "${1}"
}

function clearCheckSums() {
  docker run --rm \
    -v "${CHANGE_LOG_DIRECTORY}":"/liquibase/changelog" \
    liquibase/liquibase \
    --url="${DB_URL}" \
    --changeLogFile="${CHANGE_LOG_MASTER_FILE}" \
    --username="${DB_USERNAME}" \
    --password="${DB_PASSWORD}" \
    "${1}"
}

function listLocks() {
  docker run --rm \
    liquibase/liquibase \
    --url="${DB_URL}" \
    --username="${DB_USERNAME}" \
    --password="${DB_PASSWORD}" \
    "${1}"
}
function runCommand() {

  local inputCommand=$(echo $1 | tr [A-Z] [a-z] | tr -d '-')

  case $inputCommand in
    calculatechecksum)
      calculateCheckSum "calculate-checksum"
      ;;
    history)
      history "history"
      ;;
    clearchecksums)
      clearCheckSums "clear-checksums"
      ;;
    listlocks)
      listLocks "list-locks"
      ;;
    *)
      printLog error "Command: \"${1}\" not supported"
      usage
      return 1
      ;;
  esac
  echo "Running liquibase using the command: \"${1}\""
}

function usage() {
  cat <<EOF
  This script runs a predefined set of liquibase commands. The command is a required argument.
  The following is the list of commands that are currently supported:
  * history
  * list-locks
  * clear-checksums
  * calculate-checksum

  Examples
  * The following queries the history of liquibase on the database pointed to.
  $0 history


EOF
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1;
fi

commandString="$*"

runCommand ${commandString}
