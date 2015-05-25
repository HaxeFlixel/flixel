#!/bin/bash

haxelib run flixel-tools testdemos -$TARGET

if [ $TARGET == "flash" ]; then
	haxelib run munit test
else
	haxelib run lime test $TARGET
fi