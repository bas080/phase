#!/bin/bash
function step1 { echo "step1 output"; phase::goto step3; }
function step2 { echo "step2 should not run"; }
function step3 { echo "step3 final output"; }
phase::pipeline step1 step2 step3
