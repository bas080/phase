#!/bin/bash

# Example where a phase calls exit, stopping the pipeline.

function abort_phase {
    echo "aborting"
    exit 0
}
function step2 {
    echo "step2 (should not run)"
}

phase::pipeline abort_phase step2
