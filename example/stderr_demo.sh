#!/bin/bash
# Demonstrates that a phase function's stderr is forwarded to the
# phase process's stderr, while its stdout is captured and passed
# as stdin to the next phase (and only the last phase's stdout is
# printed to stdout).

function emitter {
  echo "emitter-stdout"
  echo "emitter-stderr" >&2
}

function forwarder {
  echo "forwarder got stdin:"
  while IFS= read -r line; do
    echo "  > $line"
  done
  echo "forwarder-done"
}

phase::pipeline emitter forwarder
