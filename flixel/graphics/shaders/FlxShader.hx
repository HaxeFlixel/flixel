package flixel.graphics.shaders;

typedef FlxShader = #if (openfl_legacy || nme) Dynamic #else  openfl.display.Shader; #end