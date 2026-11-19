# Phase

A Bash pipeline orchestrator. Write phases as plain Bash functions - `phase` handles sequencing, data flow, retries, and navigation.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/bas080/phase/main/phase -o phase
chmod +x phase
```

Or clone and use directly:

```bash
git clone https://github.com/bas080/phase
cd phase
./phase example/basic_pipeline.sh
```

## Quick start

A pipeline is a Bash script with functions and a `phase::pipeline` declaration:

```bash
cat example/basic_pipeline.sh
```
```bash
#!/bin/bash
function fetch    { echo "fetching data"; }
function transform { echo "transforming data"; }
function validate { echo "validating data"; }
function deploy   { echo "deploying data"; }
phase::pipeline fetch transform validate deploy
```

Run it:

```bash
./phase example/basic_pipeline.sh 2>&1
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
```

Each phase's **stdout** becomes the next phase's **stdin**. Stderr is passed through directly and never captured.

## Inline commands

Phases can be shell commands, not just function names. Quote anything with spaces:

```bash
cat example/command_phase.sh
```
```bash
#!/bin/bash
function fetch { echo "Fetching..."; }
function transform { echo "Transforming..."; }
phase::pipeline fetch "cat /etc/hostname" transform
```

## Navigation

By default a phase advances to the next one on success. Override with:

```bash
phase::prev          # go back one phase
phase::goto deploy   # jump to any phase by name
exit                 # stop the pipeline cleanly
```

### goto

```bash
cat example/navigation.sh
```
```bash
#!/bin/bash
function step1 { echo "step1 output"; phase::goto step3; }
function step2 { echo "step2 should not run"; }
function step3 { echo "step3 final output"; }
phase::pipeline step1 step2 step3
```

```bash
./phase example/navigation.sh 2>&1
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
```

### exit

Calling `exit [status]` stops the pipeline immediately without executing subsequent phases. The current phase's stdout is emitted and `phase` exits with the same status code:

```bash
cat example/abort.sh
```
```bash
#!/bin/bash
function step1 { echo "step1 output"; }
function step2 { echo "step2 output"; exit 0; }
function step3 { echo "step3 should not run"; }
phase::pipeline step1 step2 step3
```

```bash
./phase example/abort.sh 2>&1
```
```
Phases: step1 step2 step3
Running phase step1 (retries: 3)
Phase step1 exit=0
Phase step1 succeeded
Running phase step2 (retries: 3)
Phase step2 aborted pipeline (exit)
step2 output
```

## Retries

A phase that returns non-zero is retried up to 3 times before the pipeline fails:

```bash
cat example/retry.sh
```
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

```bash
./phase example/retry.sh 2>&1; true
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
```

The retry count is configurable via:

| Mechanism | Scope | Example |
|---|---|---|
| `phase::retries()` | Per-phase, defined in script | `phase::retries() { [[ $1 == flaky ]] && echo 5 || echo 2; }` |
| `PHASE_RETRY` | All phases | `PHASE_RETRY=5 ./phase pipeline.sh` |
| hardcoded | Last-resort default | 3 (when nothing else specified) |

`phase::retries` is a Bash function you define in your pipeline script.
It receives the phase name as `$1` and must print an integer to stdout.
If the function is absent or returns a non-positive integer, the orchestrator
falls back to `PHASE_RETRY` (default 3).

```bash
cat example/custom_retries.sh
```
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

```bash
./phase example/custom_retries.sh 2>&1; true
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
```

## Stdout vs stderr

Only stdout flows through the pipeline. Stderr from any phase is forwarded straight to the terminal:

```bash
cat example/stderr_demo.sh
```
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

```bash
./phase example/stderr_demo.sh 2>&1
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
```

## License

[GNU Affero General Public License v3.0](./LICENSE)
