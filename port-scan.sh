#!/usr/bin/env bash

# Default values
forks=10
from=1
to=1024
timeout=1
jobsfile=$(mktemp)
# Host should be the last argument
host=${!#}

# removes the temfile on exit
trap "wait; rm $jobsfile;" TERM EXIT

# The portscan function
scanPort() {
    port=$1
    response=$(timeout $timeout bash -c "echo >/dev/tcp/$host/$port" 2>&1)
    if [ $? -eq 0 ]; then
        echo "$port: is open"
    else
        if [[ $verbose ]]; then
            # check if we got a resonse or if it timed out
            if [[ $response ]]; then
                echo "$port: ${response##*: }"
            else
                echo "$port: Connection timed out ($timeout)"
            fi
        fi
    fi
    echo "Done" >>"$jobsfile"
}

usage() {
    cat <<EOF
Usage:
$(basename "$0") [OPTIONS...] HOST
  -f  Number of forks. Defaults to 10.
  -h  This help message
  -r  Portrange to scan, e.g. 10-20. Defaults to 1-1024.
  -t  Seconds to wait for a response from a port. Defaults to 1.
  -v  More verbose output.
EOF
    exit 0
}

# Parse user supplied arguments
while getopts ":hr:f:t:v" opt; do
    case $opt in
    r)
        from=${OPTARG%%-*}
        to=${OPTARG##*-}
        ;;
    h) usage ;;
    f) forks=${OPTARG} ;;
    t) timeout=${OPTARG} ;;
    v) verbose=true ;;
    \?)
        echo "Invalid option: -$OPTARG"
        echo
        usage
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument."
        echo
        usage
        exit 1
        ;;

    esac
done

# Print the options if verbose flag is set
[[ $verbose ]] && echo -e "Forks: $forks\nFrom port: $from\nTo port: $to\nTimeout: ${timeout}s\nTemfile:$jobsfile\
nHost: $host"

echo "Scanning ports $from to $to on ${host}..."

# Make the first startup of all forks
startup_to_port=$((forks + from))
for i in $(seq "$from" "$startup_to_port"); do
    scanPort "$i" &
done

# Since we already started $forks number of forks/requests..
from=$((from + forks))

# Set the rest of the ports in a queue. When a fork is done it will write to $jobsfile
# and a new one will be triggered
for port in $(seq "$from" "$to"); do
    tail -f "$jobsfile" | while read -r message; do
        scanPort "$port" &
        break
    done
done
sleep "$timeout"