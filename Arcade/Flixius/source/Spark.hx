package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class Spark extends FlxSprite
{
	var _life:Float = 1;
	var _pos:FlxPoint;
	var _source:FlxSprite;
	
	public function new() 
	{
		super(0, 0);
		loadGraphic(AssetPaths.shoot_sparks__png, true, 3, 3);
		animation.add("p", [0]);
		animation.add("e", [1]);
		_pos = FlxPoint.get();
	}
	
	public function spark(X:Float, Y:Float, Source:FlxSprite, SourceType:Int = 0):Void
	{
		_pos.x = X;
		_pos.y = Y;
		_source = Source;
		_life = 1;
		reset(_source.x + _pos.x, _source.y + _pos.y);
		animation.play((SourceType == 0) ? "p" : "e");
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (alive)
		{
			if (_life > 0)
				_life-= elapsed * 10;
			else
				kill();
		}
		x = _source.x + _pos.x;
		y = _source.y + _pos.y;
	}
}