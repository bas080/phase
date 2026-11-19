# Examples
## ./example/abort.sh

```bash
#!/bin/bash
function step1 { echo "step1 output"; }
function step2 { echo "step2 output"; exit 0; }
function step3 { echo "step3 should not run"; }
phase::pipeline step1 step2 step3
```
```
Phases: step1 step2 step3
Running phase step1 (retries: 3)
Phase step1 exit=0
Phase step1 succeeded
Running phase step2 (retries: 3)
Phase step2 aborted pipeline (exit)
step2 output
exit code: 0
```
## ./example/basic_pipeline.sh

```bash
#!/bin/bash
function fetch    { echo "fetching data"; }
function transform { echo "transforming data"; }
function validate { echo "validating data"; }
function deploy   { echo "deploying data"; }
phase::pipeline fetch transform validate deploy
```
```
Phases: fetch transform validate deploy
Running phase fetch (retries: 3)
Phase fetch exit=0
Phase fetch succeeded
Running phase transform (retries: 3)
Phase transform exit=0
Phase transform succeeded
Running phase validate (retries: 3)
Phase validate exit=0
Phase validate succeeded
Running phase deploy (retries: 3)
Phase deploy exit=0
Phase deploy succeeded
deploying data
exit code: 0
```
## ./example/command_phase.sh

```bash
#!/bin/bash
function fetch { echo "Fetching..."; }
function transform { echo "Transforming..."; }
phase::pipeline fetch "cat /etc/hostname" transform
```
```
Phases: fetch cat /etc/hostname transform
Running phase fetch (retries: 3)
Phase fetch exit=0
Phase fetch succeeded
Running phase cat /etc/hostname (retries: 3)
Phase cat /etc/hostname exit=0
Phase cat /etc/hostname succeeded
Running phase transform (retries: 3)
Phase transform exit=0
Phase transform succeeded
Transforming...
exit code: 0
```
## ./example/custom_retries.sh

```bash
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
```
```
Phases: flaky stable
Running phase flaky (retries: 5)
Phase flaky exit=1
Phase flaky retry 2/5
Phase flaky exit=1
Phase flaky retry 3/5
Phase flaky exit=1
Phase flaky retry 4/5
Phase flaky exit=1
Phase flaky retry 5/5
Phase flaky exit=1
Phase flaky failed after 5 attempts
exit code: 1
```
## ./example/exit_abort.sh

```bash
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
```
```
Phases: abort_phase step2
Running phase abort_phase (retries: 3)
Phase abort_phase aborted pipeline (exit)
aborting
exit code: 0
```
## ./example/navigation.sh

```bash
#!/bin/bash
function step1 { echo "step1 output"; phase::goto step3; }
function step2 { echo "step2 should not run"; }
function step3 { echo "step3 final output"; }
phase::pipeline step1 step2 step3
```
```
Phases: step1 step2 step3
Running phase step1 (retries: 3)
Phase step1 exit=0
Phase step1 succeeded
Running phase step3 (retries: 3)
Phase step3 exit=0
Phase step3 succeeded
step3 final output
exit code: 0
```
## ./example/retry.sh

```bash
#!/bin/bash

# Retry demonstration: a phase that always fails
# The orchestrator retries it up to 3 times before giving up.

function flaky {
    echo "flaky attempt"
    return 1
}

phase::pipeline flaky
```
```
Phases: flaky
Running phase flaky (retries: 3)
Phase flaky exit=1
Phase flaky retry 2/3
Phase flaky exit=1
Phase flaky retry 3/3
Phase flaky exit=1
Phase flaky failed after 3 attempts
exit code: 1
```
## ./example/return_fail.sh

```bash
#!/bin/bash

# A phase that returns non-zero should retry (not abort).

function flaky_return {
    echo "flaky_return attempt"
    return 1
}

phase::pipeline flaky_return
```
```
Phases: flaky_return
Running phase flaky_return (retries: 3)
Phase flaky_return exit=1
Phase flaky_return retry 2/3
Phase flaky_return exit=1
Phase flaky_return retry 3/3
Phase flaky_return exit=1
Phase flaky_return failed after 3 attempts
exit code: 1
```
## ./example/stderr_demo.sh

```bash
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
```
```
Phases: emitter forwarder
Running phase emitter (retries: 3)
emitter-stderr
Phase emitter exit=0
Phase emitter succeeded
Running phase forwarder (retries: 3)
Phase forwarder exit=0
Phase forwarder succeeded
forwarder got stdin:
  > emitter-stdout
forwarder-done
exit code: 0
```
