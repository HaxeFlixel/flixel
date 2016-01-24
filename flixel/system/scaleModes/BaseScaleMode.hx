package flixel.system.scaleModes;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxHorizontalAlign;
import flixel.util.FlxVerticalAlign;

@:allow(flixel.FlxGame)
class BaseScaleMode
{
	public static var gWidth:Int;
	public static var gHeight:Int;
	
	public var deviceSize(default, null):FlxPoint;
	public var gameSize(default, null):FlxPoint;
	public var scale(default, null):FlxPoint;
	public var offset(default, null):FlxPoint;
	
	public var horizontalAlign(default, set):FlxHorizontalAlign = CENTER;
	public var verticalAlign(default, set):FlxVerticalAlign = CENTER;
	
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
		switch (horizontalAlign)
		{
			case FlxHorizontalAlign.LEFT:
				offset.x = 0;
			case FlxHorizontalAlign.CENTER:
				offset.x = Math.ceil((deviceSize.x - gameSize.x) * 0.5);
			case FlxHorizontalAlign.RIGHT:
				offset.x = deviceSize.x - gameSize.x;
		}
	}
	
	private function updateOffsetY():Void
	{
		switch (verticalAlign)
		{
			case FlxVerticalAlign.TOP:
				offset.y = 0;
			case FlxVerticalAlign.CENTER:
				offset.y = Math.ceil((deviceSize.y - gameSize.y) * 0.5);
			case FlxVerticalAlign.BOTTOM:
				offset.y = deviceSize.y - gameSize.y;
		}
	}
	
	private function updateGamePosition():Void
	{
		if (FlxG.game == null)
			return;
		
		FlxG.game.x = offset.x;
		FlxG.game.y = offset.y;
	}
	
	private function set_horizontalAlign(value:FlxHorizontalAlign):FlxHorizontalAlign
	{
		horizontalAlign = value;
		if (offset != null)
		{
			updateOffsetX();
			updateGamePosition();
		}
		return value;
	}
	
	private function set_verticalAlign(value:FlxVerticalAlign):FlxVerticalAlign
	{
		verticalAlign = value;
		if (offset != null)
		{
			updateOffsetY();
			updateGamePosition();
		}
		return value;
	}
}