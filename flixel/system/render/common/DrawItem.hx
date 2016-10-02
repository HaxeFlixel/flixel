package flixel.system.render.common;

import openfl.Vector;

/**
 * ...
 * @author Zaphod
 */
typedef DrawData<T> =	#if ((openfl >= "4.0.0") || flash)
							Vector<T>
						#else 
							Array<T>
						#end;

typedef FlxDrawQuadsItem =		#if (openfl >= "4.0.0")
									flixel.system.render.hardware.gl.FlxDrawQuadsItem
								#else 
									flixel.system.render.hardware.tile.FlxDrawQuadsItem
								#end;

typedef FlxDrawTrianglesItem =	#if (openfl >= "4.0.0") 
									flixel.system.render.hardware.gl.FlxDrawTrianglesItem 
								#else 
									flixel.system.render.hardware.tile.FlxDrawTrianglesItem 
								#end;

enum FlxDrawItemType 
{
	TILES;
	TRIANGLES;
}