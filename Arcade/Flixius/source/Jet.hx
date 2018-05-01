package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Jet extends FlxSprite
{
	var _target:FlxSprite;
	var _targetType:Int = 0;
	var _pos:FlxPoint;
	
	public function new(Target:FlxSprite, TargetType:Int = 0) 
	{
		super();
		loadGraphic(AssetPaths.thrust__png, true, 8, 8);
		
		_pos = FlxPoint.get(0,0);
		
		_target = Target;
		_targetType = TargetType;
		
		animation.add("thrust", [0, 1, 2], 12);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		
		if (_targetType == 0)
		{
			facing = FlxObject.RIGHT;
			_pos.x = -8;
			_pos.y = _target.height - 8;
		}
		else
		{
			facing = FlxObject.LEFT;
			_pos.x = _target.width;
			_pos.y = 0;
		}
		x = _target.x + _pos.x;
		y = _target.y + _pos.y;
		animation.play("thrust");
	}
	
	override public function draw():Void 
	{
		if (!_target.isOnScreen() || isOnScreen())
		{
			x = _target.x + _pos.x;
			y = _target.y + _pos.y;
		}
		super.draw();
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (alive && !_target.alive)
		{
			kill();
		}
	}
}