#!/bin/bash
function fetch { echo "Fetching..."; }
function transform { echo "Transforming..."; }
phase::pipeline fetch "cat /etc/hostname" transform
