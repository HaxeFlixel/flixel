#!/bin/bash

echo "Starting unit tests..."
cd unit
if [ $TARGET == "flash" ]; then
	haxelib run munit test
elif [ $TARGET != "html5" ]; then
	haxelib run lime test $TARGET
fi