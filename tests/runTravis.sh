#!/bin/bash

if [ $TARGET == "flash" ]; then
	haxelib run munit test
elif [ $TARGET != "html5" ]; then
	haxelib run lime test $TARGET
fi

haxelib run flixel-tools testdemos -$TARGET