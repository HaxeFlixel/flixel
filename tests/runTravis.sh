#!/bin/bash

if [ $TARGET == "flash" ]; then
	haxelib run munit test
elif [ $TARGET != "html5" ]; then
	haxelib run lime test $TARGET
fi

if [ $TARGET == "cpp" ]; then
	haxelib run flixel-tools td $TARGET Mode "RPG Interface" FlxNape
else
	haxelib run flixel-tools td $TARGET
fi