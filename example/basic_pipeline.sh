#!/bin/bash
function fetch    { echo "fetching data"; }
function transform { echo "transforming data"; }
function validate { echo "validating data"; }
function deploy   { echo "deploying data"; }
phase::pipeline fetch transform validate deploy
