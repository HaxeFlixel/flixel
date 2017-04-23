package flixel.system.render.common;

import openfl.Vector;

/**
 * ...
 * @author Zaphod
 */
typedef FlxDrawQuadsCommand =		#if (openfl >= "4.0.0")
										flixel.system.render.hardware.gl.FlxDrawQuadsCommand
									#else 
										flixel.system.render.hardware.tile.FlxDrawQuadsCommand
									#end;

typedef FlxDrawTrianglesCommand =	#if (openfl >= "4.0.0") 
										flixel.system.render.hardware.gl.FlxDrawTrianglesCommand  
									#else 
										flixel.system.render.hardware.tile.FlxDrawTrianglesCommand 
									#end;

enum FlxDrawItemType 
{
	QUADS;
	TRIANGLES;
}