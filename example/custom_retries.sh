#!/bin/bash

# Custom retry counts per phase via phase::retries()

function flaky { echo "flaky attempt $RANDOM"; return 1; }
function stable { echo "stable output"; }

phase::retries() {
    case "$1" in
        flaky) echo 5 ;;
        *)     echo 2 ;;
    esac
}

phase::pipeline flaky stable
