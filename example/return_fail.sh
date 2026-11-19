#!/bin/bash

# A phase that returns non-zero should retry (not abort).

function flaky_return {
    echo "flaky_return attempt"
    return 1
}

phase::pipeline flaky_return
