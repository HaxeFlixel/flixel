package flixel.system.scaleModes;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxHorizontalAlign;
import flixel.util.FlxVerticalAlign;

/**
 * The base class from which all other scale modes extend from.
 * You can implement your own scale mode by extending this class and overriding the appropriate methods.
 * 
 * The default behavior of `BaseScaleMode` matches that of `FillScaleMode`.
 */
class BaseScaleMode
{
	public var deviceSize(default, null):FlxPoint;
	public var gameSize(default, null):FlxPoint;
	public var scale(default, null):FlxPoint;
	public var offset(default, null):FlxPoint;

	public var horizontalAlign(default, set):FlxHorizontalAlign = CENTER;
	public var verticalAlign(default, set):FlxVerticalAlign = CENTER;

	public function new()
	{
		deviceSize = FlxPoint.get();
		gameSize = FlxPoint.get();
		scale = FlxPoint.get();
		offset = FlxPoint.get();
	}

	public function onMeasure(Width:Int, Height:Int):Void
	{
		FlxG.width = FlxG.initialWidth;
		FlxG.height = FlxG.initialHeight;

		updateGameSize(Width, Height);
		updateDeviceSize(Width, Height);
		updateScaleOffset();
		updateGamePosition();
	}

	function updateGameSize(Width:Int, Height:Int):Void
	{
		gameSize.set(Width, Height);
	}

	function updateDeviceSize(Width:Int, Height:Int):Void
	{
		deviceSize.set(Width, Height);
	}

	function updateScaleOffset():Void
	{
		scale.x = gameSize.x / (FlxG.width * FlxG.initialZoom);
		scale.y = gameSize.y / (FlxG.height * FlxG.initialZoom);
		updateOffsetX();
		updateOffsetY();
	}

	function updateOffsetX():Void
	{
		offset.x = switch (horizontalAlign)
		{
			case FlxHorizontalAlign.LEFT:
				0;
			case FlxHorizontalAlign.CENTER:
				Math.ceil((deviceSize.x - gameSize.x) * 0.5);
			case FlxHorizontalAlign.RIGHT:
				deviceSize.x - gameSize.x;
		}
	}

	function updateOffsetY():Void
	{
		offset.y = switch (verticalAlign)
		{
			case FlxVerticalAlign.TOP:
				0;
			case FlxVerticalAlign.CENTER:
				Math.ceil((deviceSize.y - gameSize.y) * 0.5);
			case FlxVerticalAlign.BOTTOM:
				deviceSize.y - gameSize.y;
		}
	}

	function updateGamePosition():Void
	{
		if (FlxG.game == null)
			return;

		FlxG.game.x = offset.x;
		FlxG.game.y = offset.y;
	}

	function set_horizontalAlign(value:FlxHorizontalAlign):FlxHorizontalAlign
	{
		horizontalAlign = value;
		if (offset != null)
		{
			updateOffsetX();
			updateGamePosition();
		}
		return value;
	}

	function set_verticalAlign(value:FlxVerticalAlign):FlxVerticalAlign
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
