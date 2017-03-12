#!/bin/bash

isCommand() {
  for cmd in \
    "preview" \
    "clear" \
    "deploy" \
    "generate" \
    "help" \
    "list" \
    "preview" \
    "self-update" \
    "selfupdate" \
    "travis-auto-deploy" \
    "init:template"
  do
    if [ -z "${cmd#"$1"}" ]; then
      return 0
    fi
  done

  return 1
}

# check if the first argument passed in looks like a flag
if [ "$(printf %c "$1")" = '-' ]; then
  set -- /sbin/tini -- couscous "$@"
# check if the first argument passed in is composer
elif [ "$1" = 'couscous' ]; then
  set -- /sbin/tini -- "$@"
# check if the first argument passed in matches a known command
elif isCommand "$1"; then
  set -- /sbin/tini -- couscous "$@"
fi

exec "$@"
