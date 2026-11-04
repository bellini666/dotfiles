#!/bin/bash
# Assertion helpers shared by the sandbox test scripts.

fails=0

must_fail() {
  if bash -c "$1" >/dev/null 2>&1; then
    echo "OPEN    $1"
    fails=$((fails + 1))
  else
    echo "denied  $1"
  fi
}

must_pass() {
  if bash -c "$1" >/dev/null 2>&1; then
    echo "ok      $1"
  else
    echo "BROKEN  $1"
    fails=$((fails + 1))
  fi
}
