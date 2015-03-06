package flixel.system.scaleModes;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxPoint;

@:allow(flixel.FlxGame)
class BaseScaleMode
{
	public static var gWidth:Int;
	public static var gHeight:Int;
	
	public var deviceSize(default, null):FlxPoint;
	public var gameSize(default, null):FlxPoint;
	public var scale(default, null):FlxPoint;
	public var offset(default, null):FlxPoint;
	
	public var hAlign(default, set):HAlign = HAlign.Center;
	public var vAlign(default, set):VAlign = VAlign.Center;
	
	private static var zoom:FlxPoint = FlxPoint.get();
	
	public function new()
	{
		deviceSize = FlxPoint.get();
		gameSize = FlxPoint.get();
		scale = FlxPoint.get();
		offset = FlxPoint.get();
	}
	
	public function onMeasure(Width:Int, Height:Int):Void
	{
		FlxG.width = BaseScaleMode.gWidth;
		FlxG.height = BaseScaleMode.gHeight;
		
		updateGameSize(Width, Height);
		updateDeviceSize(Width, Height);
		updateScaleOffset();
		updateGamePosition();
	}
	
	private function updateGameSize(Width:Int, Height:Int):Void
	{
		gameSize.set(Width, Height);
	}
	
	private function updateDeviceSize(Width:Int, Height:Int):Void
	{
		deviceSize.set(Width, Height);
	}
	
	private function updateScaleOffset():Void
	{
		scale.x = gameSize.x / (FlxG.width * FlxG.initialZoom);
		scale.y = gameSize.y / (FlxG.height * FlxG.initialZoom);
		updateOffsetX();
		updateOffsetY();
	}
	
	private function updateOffsetX():Void
	{
		switch (hAlign)
		{
			case HAlign.Left:
				offset.x = 0;
			case HAlign.Center:
				offset.x = Math.ceil((deviceSize.x - gameSize.x) * 0.5);
			case HAlign.Right:
				offset.x = deviceSize.x - gameSize.x;
		}
	}
	
	private function updateOffsetY():Void
	{
		switch (vAlign)
		{
			case VAlign.Top:
				offset.y = 0;
			case VAlign.Center:
				offset.y = Math.ceil((deviceSize.y - gameSize.y) * 0.5);
			case VAlign.Bottom:
				offset.y = deviceSize.y - gameSize.y;
		}
	}
	
	private function updateGamePosition():Void
	{
		FlxG.game.x = offset.x;
		FlxG.game.y = offset.y;
	}
	
	private function set_hAlign(value:HAlign):HAlign
	{
		hAlign = value;
		updateOffsetX();
		updateGamePosition();
	}
	
	private function set_vAlign(value:VAlign):VAlign
	{
		vAlign = value;
		updateOffsetY();
		updateGamePosition();
	}
}

enum HAlign 
{
	Left;
	Center;
	Right;
}

enum VAlign
{
	Top;
	Center;
	Bottom;
}