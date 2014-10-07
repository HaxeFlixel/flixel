package flixel.util.loaders;

import flash.geom.Rectangle;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.math.FlxPoint;

class TextureAtlasFrame implements IFlxDestroyable
{
	public var name:String = null;
	public var frame:Rectangle = null;
	
	public var rotated:Bool = false;
	public var trimmed:Bool = false;
	public var sourceSize:FlxPoint = null;
	public var offset:FlxPoint = null;
	
	public var additionalAngle:Int = 0;
	
	public function new() {}
	
	public function destroy():Void
	{
		name = null;
		frame = null;
		sourceSize = null;
		offset = null;
	}
}