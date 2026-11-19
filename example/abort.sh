#!/bin/bash
function step1 { echo "step1 output"; }
function step2 { echo "step2 output"; exit 0; }
function step3 { echo "step3 should not run"; }
phase::pipeline step1 step2 step3
