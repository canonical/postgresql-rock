#!/bin/sh
# Run `initdb` if PGDATA directory does not exist
set -eu

_sleep() {
    # Sleep for 1.5 seconds
    # If a pebble service exits before 1 second elapses, pebble considers it failed regardless if
    # the exit code is 0.
    # > If the command is still running at the end of the 1 second window, the start is considered
    #   successful.
    # > If the command exits within the 1 second window, Pebble retries the command after a
    #   configurable backoff
    # https://ubuntu.com/docs/pebble/reference/cli-commands/#reference-pebble-start-command
    # `sleep` is not included in bare base rock
    read -r up _rest < /proc/uptime
    seconds=${up%%.*}
    centiseconds=${up#*.}
    start_centiseconds=$(( seconds * 100 + ${centiseconds#0} ))
    while true; do
        read -r up _rest < /proc/uptime
        seconds=${up%%.*}
        centiseconds=${up#*.}
        [ $(( seconds * 100 + ${centiseconds#0} )) -ge $(( start_centiseconds + 150 )) ] && break
    done
}

if [ -d "${PGDATA}" ]; then
    printf "${PGDATA} already exists" >&2
    _sleep
    exit 0
fi
/usr/lib/postgresql/18/bin/initdb "$@"
_sleep
