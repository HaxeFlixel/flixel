package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Hit extends FlxSprite
{
	var _pos:FlxPoint;
	var _player:FlxSprite;

	public function new(P:Player)
	{
		super(0, 0);
		loadGraphic(AssetPaths.hit__png, true, 9, 9);
		animation.add("hit", [0, 1, 2], 12, false);
		_pos = FlxPoint.get();
		_player = P;
	}

	public function hit():Void
	{
		_pos.x = Std.int(FlxG.random.float(-4, _player.width - 4));
		_pos.y = Std.int(FlxG.random.float(-4, _player.height - 4));
		reset(_player.x + _pos.x, _player.y + _pos.y);
		animation.play("hit");
	}

	override public function draw():Void
	{
		x = _player.x + _pos.x;
		y = _player.y + _pos.y;
		super.draw();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (alive && animation.finished)
			kill();
	}
}
