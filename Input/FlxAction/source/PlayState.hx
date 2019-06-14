package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class PlayState extends FlxState
{
	public var player:Player;

	var _level:TiledLevel;
	var _howto:FlxText;

	override public function create():Void
	{
		FlxG.mouse.visible = false;
		bgColor = 0xFF18A068;

		// Load the level's tilemaps
		_level = new TiledLevel("assets/data/map.tmx");

		// Add tilemaps
		add(_level.backgroundTiles);

		// Add tilemaps
		add(_level.foregroundTiles);

		// Load player and objects of the Tiled map
		_level.loadObjects(this);

		#if !mobile
		// Set and create Txt Howto
		_howto = new FlxText(0, 20, FlxG.width);
		_howto.scale.set(2, 2);
		_howto.alignment = CENTER;
		_howto.text = "Digital: ARROWS, WASD, D-PAD, BUTTONS, LEFT STICK\nAnalog: MOUSE motion, RIGHT STICK, TRIGGERS";
		_howto.scrollFactor.set(0, 0);
		add(_howto);
		#end
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// Collide with foreground tile layer
		_level.collideWithLevel(player);
	}

	override public function destroy():Void
	{
		super.destroy();

		player = null;
		_level = null;
		_howto = null;
	}
}
