package flixel.system.render;

import openfl.Vector;

/**
 * ...
 * @author Zaphod
 */
typedef DrawData<T> = #if flash Vector<T> #else Array<T> #end;

typedef FlxDrawBaseItem<T> = #if (openfl >= "4.0.0") flixel.system.render.gl.FlxDrawBaseItem<T> #else flixel.system.render.tile.FlxDrawBaseItem<T> #end;
typedef FlxDrawQuadsItem = #if (openfl >= "4.0.0") flixel.system.render.gl.FlxDrawQuadsItem #else flixel.system.render.tile.FlxDrawQuadsItem #end;
typedef FlxDrawTrianglesItem = #if (openfl >= "4.0.0") flixel.system.render.gl.FlxDrawTrianglesItem #else flixel.system.render.tile.FlxDrawTrianglesItem #end;

enum FlxDrawItemType 
{
	TILES;
	TRIANGLES;
}