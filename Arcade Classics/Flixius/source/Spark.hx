package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.FlxPointer;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Spark extends FlxSprite
{

	private var _life:Float = 1;
	private var _pos:FlxPoint;
	private var _source:FlxSprite;
	
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
		if (SourceType == 0)
		{
			animation.play("p");
		}
		else
		{
			animation.play("e");
		}
		
	}
	
	override public function draw():Void 
	{
		
		x = _source.x + _pos.x;
		y = _source.y + _pos.y;
		super.draw();	
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (alive)
		{
			
			if (_life > 0)
				_life-= FlxG.elapsed * 10;
			else
				kill();
		}
	}
	
}