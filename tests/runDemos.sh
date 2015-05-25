#!/bin/bash

echo "Compiling demos..."
if [ $TARGET == "cpp" ]; then
	haxelib run flixel-tools td $TARGET Mode "RPG Interface" FlxNape
else
	haxelib run flixel-tools td $TARGET
fi