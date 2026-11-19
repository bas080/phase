#!/bin/bash

# Retry demonstration: a phase that always fails
# The orchestrator retries it up to 3 times before giving up.

function flaky {
    echo "flaky attempt"
    return 1
}

phase::pipeline flaky
