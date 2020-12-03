#!/bin/sh
# Prevent computer from sleeping, suspending, hibernating, etc.

# Echo help message.
usage() {
    echo \
"Usage: $(basename "$0") [--sweet-dreams] [--help]

insomniac.sh - Prevent computer from sleeping, suspending, hibernating, etc.

Options:
  -s, --sweet-dreams  resume normal power settings
  -h, --help          show this help message and exit
"
}

sleeps='sleep.target suspend.target hibernate.target hybrid-sleep.target'
case "$1" in
    "")
        # shellcheck disable=SC2086
        systemctl mask --runtime $sleeps
        ;;
    -s|--sweet-dreams)
        # shellcheck disable=SC2086
        systemctl unmask --runtime $sleeps
        ;;
    -h|--help|*)
        usage
        ;;
esac
