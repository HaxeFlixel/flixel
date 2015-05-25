#!/bin/bash

# unit tests
cd unit

if [ $TARGET == "flash" ]; then
	haxelib run munit test
elif [ $TARGET != "html5" ]; then
	haxelib run lime test $TARGET
fi

# coverage tests

cd ../coverage

haxelib run lime build $TARGET -Dcoverage1
haxelib run lime build $TARGET -Dcoverage2

# demos
if [ $TARGET == "cpp" ]; then
	haxelib run flixel-tools td $TARGET Mode "RPG Interface" FlxNape
else
	haxelib run flixel-tools td $TARGET
fi