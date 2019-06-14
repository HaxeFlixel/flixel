package;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	var _map:FlxTilemap;

	var _redEmitter:FlxEmitter;
	var _blueEmitter:FlxEmitter;

	var _redScore:Int = 0;
	var _blueScore:Int = 0;

	var _redScoreText:FlxText;
	var _blueScoreText:FlxText;

	override public function create():Void
	{
		bgColor = 0xff331133;

		super.create();

		var mapRow:String = "0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0\n\r";
		var mapData:String = '';
		for (i in 0...Std.int(FlxG.height / 16))
		{
			mapData += mapRow;
		}

		_map = new FlxTilemap();
		_map.loadMapFromCSV(mapData, AssetPaths.tiles__png, 16, 16);

		// Tile #1 will only collide on it's right-side, and will call 'leftHit' when it does.
		_map.setTileProperties(1, FlxObject.RIGHT, leftHit);
		// Tile #2 will only collide on it's left-side, and will call 'rightHit' when it does.
		_map.setTileProperties(2, FlxObject.LEFT, rightHit);

		add(_map);

		_redEmitter = createEmitter(FlxColor.RED);
		_redEmitter.launchAngle.set(-45, -30);

		_blueEmitter = createEmitter(FlxColor.BLUE);
		_blueEmitter.x = FlxG.width;
		_blueEmitter.launchAngle.set(-150, -135);

		add(_redEmitter);
		add(_blueEmitter);

		_redScoreText = createText(4, 4, FlxTextAlign.LEFT, FlxColor.RED);
		add(_redScoreText);

		_blueScoreText = createText(FlxG.width - 104, 4, FlxTextAlign.LEFT, FlxColor.BLUE);
		_blueScoreText.alignment = FlxTextAlign.RIGHT;
		add(_blueScoreText);

		var instructionText = createText(Std.int((FlxG.width / 2) - 50), 0, FlxTextAlign.CENTER, FlxColor.PURPLE);
		instructionText.text = "Press R to Reset";
		instructionText.y = FlxG.height - instructionText.height - 4;
		add(instructionText);
	}

	function createEmitter(Color:FlxColor):FlxEmitter
	{
		var emitter = new FlxEmitter(0, Std.int(FlxG.height * .6));
		emitter.makeParticles(12, 12, Color, 50);
		emitter.launchMode = FlxEmitterMode.CIRCLE;
		emitter.speed.set(400, 900);
		emitter.allowCollisions = FlxObject.ANY;
		emitter.elasticity.set(.8, .8);
		emitter.acceleration.set(0, 1200, 0, 1200);
		emitter.start(false, .8);
		return emitter;
	}

	function createText(X:Int, Y:Int, Align:FlxTextAlign, Color:FlxColor):FlxText
	{
		var text = new FlxText(X, Y, 100);
		text.color = FlxColor.WHITE;
		text.setBorderStyle(FlxTextBorderStyle.SHADOW, Color, 2, 2);
		text.alignment = Align;
		return text;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		FlxG.collide(_map, _redEmitter);
		FlxG.collide(_map, _blueEmitter);

		if (Std.string(_redScore) != _redScoreText.text)
			_redScoreText.text = Std.string(_redScore);
		if (Std.string(_blueScore) != _blueScoreText.text)
			_blueScoreText.text = Std.string(_blueScore);

		if (FlxG.keys.justReleased.R)
			FlxG.camera.flash(FlxColor.BLACK, .1, FlxG.resetState);
	}

	function removeTile(Tile:FlxTile):Void
	{
		_map.setTileByIndex(Tile.mapIndex, 0, true);
	}

	function leftHit(Tile:FlxObject, Particle:FlxObject):Void
	{
		removeTile(cast Tile);
		_blueScore++;
	}

	function rightHit(Tile:FlxObject, Particle:FlxObject):Void
	{
		removeTile(cast Tile);
		_redScore++;
	}
}
