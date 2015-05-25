#!/bin/bash

echo "Starting coverage tests..."
cd coverage
haxelib run lime build $TARGET -Dcoverage1
haxelib run lime build $TARGET -Dcoverage2