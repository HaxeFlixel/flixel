package;

import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	
	private var _map:FlxTilemap;
	private var _leftEmitter:FlxTypedEmitter<FlxParticle>;
	private var _rightEmitter:FlxTypedEmitter<FlxParticle>;
	
	private var _scores:Array<Int> = [0, 0];
	
	private static inline var RED:Int = 0;
	private static inline var BLUE:Int = 1;
	
	private var _txtScoreRed:FlxText;
	private var _txtScoreBlue:FlxText;
	
	
	override public function create():Void
	{
		bgColor = 0xff331133;
		
		super.create();
		
		var mapRow:String = "0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0\n\r";
		var mapData:String='';
		for (i in 0...Std.int(FlxG.height / 16))
		{
			mapData += mapRow;
		}
		
		_map = new FlxTilemap();
		_map.loadMapFromCSV(mapData, AssetPaths.tiles__png, 16, 16);
		
		_map.setTileProperties(1, FlxObject.RIGHT, leftHit); // Tile #1 will only collide on it's right-side, and will call 'leftHit' when it does.
		_map.setTileProperties(2, FlxObject.LEFT, rightHit); // Tile #2 will only collide on it's left-side, and will call 'rightHit' when it does.
		
		add(_map);
		
		_leftEmitter = new FlxTypedEmitter<FlxParticle>(0, Std.int(FlxG.height * .6), 50);
		_leftEmitter.makeParticles(12, 12, FlxColor.RED, 50);
		_leftEmitter.launchMode = FlxEmitterMode.CIRCLE;
		_leftEmitter.launchAngle.set( -45, -30);
		_leftEmitter.speed.set(400, 900);
		_leftEmitter.allowCollisions = FlxObject.ANY;
		_leftEmitter.elasticity.set(.8, .8);
		_leftEmitter.acceleration.set(0, 1200, 0, 1200);
		_leftEmitter.start(false,.8);
		
		_rightEmitter = new FlxTypedEmitter<FlxParticle>(FlxG.width-1, Std.int(FlxG.height * .6), 50);
		_rightEmitter.makeParticles(12, 12, FlxColor.BLUE, 50);
		_rightEmitter.launchMode = FlxEmitterMode.CIRCLE;
		_rightEmitter.launchAngle.set( -150, -135);
		_rightEmitter.speed.set(400, 900);
		_rightEmitter.allowCollisions = FlxObject.ANY;
		_rightEmitter.elasticity.set(.8, .8);
		_rightEmitter.acceleration.set(0, 1200, 0, 1200);
		_rightEmitter.start(false,.8);
		
		
		add(_leftEmitter);
		add(_rightEmitter);
		
		_txtScoreRed = new FlxText(4, 4, 100,"0");
		_txtScoreRed.color = FlxColor.WHITE;
		_txtScoreRed.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.RED, 2, 2);
		add(_txtScoreRed);
		
		_txtScoreBlue = new FlxText(FlxG.width - 104, 4, 100,"0");
		_txtScoreBlue.color = FlxColor.WHITE;
		_txtScoreBlue.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLUE, 2, 2);
		_txtScoreBlue.alignment = FlxTextAlign.RIGHT;
		add(_txtScoreBlue);
		
		var _txtInst:FlxText = new FlxText((FlxG.width / 2) - 50, 0, 100, "Press R to Reset");
		_txtInst.y = FlxG.height - _txtInst.height - 4;
		_txtInst.color = FlxColor.WHITE;
		_txtInst.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.PURPLE, 2, 2);
		_txtInst.alignment = FlxTextAlign.CENTER;
		add(_txtInst);
		
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		FlxG.collide(_map, _leftEmitter);
		FlxG.collide(_map, _rightEmitter);
		
		if (Std.string(_scores[RED]) != _txtScoreRed.text)
			_txtScoreRed.text = Std.string(_scores[RED]);
		if (Std.string(_scores[BLUE]) != _txtScoreBlue.text)
			_txtScoreBlue.text = Std.string(_scores[BLUE]);	
			
		if (FlxG.keys.justReleased.R)
		{
			FlxG.camera.flash(FlxColor.BLACK, .1, FlxG.resetState);
		}
	}	
	
	private function removeTile(T:FlxTile):Void
	{
		_map.setTileByIndex(T.mapIndex, 0, true);
	}
	
	private function leftHit(T:FlxObject, P:FlxObject):Void
	{
		removeTile(cast T);
		_scores[BLUE]++;
		
	}
	
	private function rightHit(T:FlxObject, P:FlxObject):Void
	{
		removeTile(cast T);
		_scores[RED]++;
	}
	
}