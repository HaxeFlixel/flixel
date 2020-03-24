package;

import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class PongSprite extends FlxSprite
{
	public var secondColor:Int;
	public var minVelocity:FlxPoint;

	static public inline var SOLID:Int = 0;
	static public inline var GRADIENT:Int = 1;

	public function new(X:Float, Y:Float, Width:Int, Height:Int, Color:Int, Style:Int = SOLID, ?SecondColor:Int)
	{
		var Graphic:BitmapData = new BitmapData(Width, Height, false, Color);

		if (Style == GRADIENT && SecondColor != null)
		{
			secondColor = SecondColor;
			fillWithGradient(Graphic, color, secondColor);
		}

		super(X, Y, Graphic);
	}

	override public function update(elapsed:Float):Void
	{
		if (minVelocity != null)
		{
			if (Math.abs(velocity.x) < minVelocity.x)
			{
				var sign:Int = (velocity.x < 0) ? -1 : 1;
				velocity.x = minVelocity.x * sign;
			}
			if (Math.abs(velocity.y) < minVelocity.y)
			{
				var sign:Int = (velocity.y < 0) ? -1 : 1;
				velocity.y = minVelocity.y * sign;
			}
		}

		super.update(elapsed);
	}

	public function fillWithGradient(Bd:BitmapData, Color:Int, SecondColor:Int):Void
	{
		color = Color;
		secondColor = SecondColor;

		var w:Int = Bd.width;
		var h:Int = Bd.height;
		var increment:Float = 1 / h;
		Bd = new BitmapData(w, h, false, Color);

		for (yPos in 0...h)
		{
			for (xPos in 0...w)
			{
				if (xPos % increment == 0)
					Bd.setPixel(xPos, yPos, secondColor);
			}
		}
	}

	public var mx(get, never):Int;

	function get_mx():Int
	{
		return Std.int(x + width / 2);
	}

	public var my(get, never):Int;

	function get_my():Int
	{
		return Std.int(y + height / 2);
	}

	public var fx(get, never):Int;

	function get_fx():Int
	{
		return Std.int(x + width);
	}

	public var fy(get, never):Int;

	function get_fy():Int
	{
		return Std.int(y + height);
	}
}
