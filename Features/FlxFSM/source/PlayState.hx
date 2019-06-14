package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

using StringTools;

class PlayState extends FlxState
{
	var _map:FlxTilemap;
	var _slime:Slime;
	var _powerup:FlxSprite;

	var _info:String = "LEFT & RIGHT to move, UP to jump\nDOWN (in the air) " + "to ground-pound.\nR to Reset\n\nCurrent State: {STATE}";
	var _txtInfo:FlxText;

	override public function create():Void
	{
		bgColor = 0xff661166;
		super.create();

		_map = new FlxTilemap();
		_map.loadMapFromArray([
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
			1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
			1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
			1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
			1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
			1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
			1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
			1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
			1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1,
			1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
			1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
			1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
			1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
		], 20, 15, "assets/tiles.png", 16, 16);
		add(_map);

		_slime = new Slime(192, 128);
		add(_slime);

		_powerup = new FlxSprite(48, 208, "assets/powerup.png");
		add(_powerup);

		_txtInfo = new FlxText(16, 16, -1, _info);
		add(_txtInfo);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		FlxG.collide(_map, _slime);
		FlxG.overlap(_slime, _powerup, getPowerup);

		_txtInfo.text = _info.replace("{STATE}", Type.getClassName(_slime.fsm.stateClass));

		if (FlxG.keys.justReleased.R)
		{
			FlxG.camera.flash(FlxColor.BLACK, .1, FlxG.resetState);
		}
	}

	function getPowerup(slime:Slime, particle:FlxSprite):Void
	{
		slime.fsm.transitions.replace(Slime.Jump, Slime.SuperJump);
		slime.fsm.transitions.add(Slime.Jump, Slime.Idle, Slime.Conditions.grounded);

		particle.kill();
	}
}
