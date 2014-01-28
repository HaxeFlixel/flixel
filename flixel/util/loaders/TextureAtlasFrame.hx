package flixel.util.loaders;

import flash.geom.Rectangle;
import flixel.interfaces.IFlxDestroyable;
import flixel.util.FlxPoint;

class TextureAtlasFrame implements IFlxDestroyable
{
	public var name:String = null;
	public var frame:Rectangle = null;
	
	public var rotated:Bool = false;
	public var trimmed:Bool = false;
	public var sourceSize:FlxPoint = null;
	public var offset:FlxPoint = null;
	
	public function new() {}
	
	public function destroy():Void
	{
		name = null;
		frame = null;
		sourceSize = null;
		offset = null;
	}
}