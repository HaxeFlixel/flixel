package;

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
	
	private var _scoreRed:Int = 0;
	private var _scoreBlue:Int = 0;
	
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
		
		// Tile #1 will only collide on it's right-side, and will call 'leftHit' when it does.
		_map.setTileProperties(1, FlxObject.RIGHT, leftHit); 
		// Tile #2 will only collide on it's left-side, and will call 'rightHit' when it does.
		_map.setTileProperties(2, FlxObject.LEFT, rightHit); 
		
		add(_map);
		
		_leftEmitter = createEmitter(FlxColor.RED);
		_rightEmitter = createEmitter(FlxColor.BLUE);
		
		add(_leftEmitter);
		add(_rightEmitter);
		
		_txtScoreRed = createText(4, 4, FlxTextAlign.LEFT, FlxColor.RED);
		add(_txtScoreRed);
		
		_txtScoreBlue =  createText(FlxG.width - 104, 4, FlxTextAlign.LEFT, FlxColor.BLUE);
		add(_txtScoreBlue);
		
		var _txtInst = createText(Std.int((FlxG.width / 2) - 50), 0, FlxTextAlign.CENTER, FlxColor.PURPLE);
		_txtInst.text = "Press R to Reset";
		_txtInst.y = FlxG.height - _txtInst.height - 4;
		add(_txtInst);
		
	}

	
	private function createText(X:Int, Y:Int, Align:FlxTextAlign, Color:FlxColor):FlxText
	{
		var _text:FlxText = new FlxText(X, Y, 100);
		_text.color = FlxColor.WHITE;
		_text.setBorderStyle(FlxTextBorderStyle.SHADOW, Color, 2, 2);
		_text.alignment = Align;
		return _text;
	}
	
	private function createEmitter(Color:FlxColor):FlxTypedEmitter<FlxParticle>
	{
		var isRed:Bool = Color == FlxColor.RED;
		
		var emitter:FlxTypedEmitter<FlxParticle> = new FlxTypedEmitter<FlxParticle>(isRed ? 0 : FlxG.width-1, Std.int(FlxG.height * .6), 50);
		emitter.makeParticles(12, 12, Color, 50);
		emitter.launchMode = FlxEmitterMode.CIRCLE;
		if (isRed)
			emitter.launchAngle.set( -45, -30);
		else
			emitter.launchAngle.set( -150, -135);
		emitter.speed.set(400, 900);
		emitter.allowCollisions = FlxObject.ANY;
		emitter.elasticity.set(.8, .8);
		emitter.acceleration.set(0, 1200, 0, 1200);
		emitter.start(false, .8);
		
		return emitter;
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		FlxG.collide(_map, _leftEmitter);
		FlxG.collide(_map, _rightEmitter);
		
		if (Std.string(_scoreRed) != _txtScoreRed.text)
			_txtScoreRed.text = Std.string(_scoreRed);
		if (Std.string(_scoreBlue) != _txtScoreBlue.text)
			_txtScoreBlue.text = Std.string(_scoreBlue);	
			
		if (FlxG.keys.justReleased.R)
		{
			FlxG.camera.flash(FlxColor.BLACK, .1, FlxG.resetState);
		}
	}	
	
	private function removeTile(Tile:FlxTile):Void
	{
		_map.setTileByIndex(Tile.mapIndex, 0, true);
	}
	
	private function leftHit(Tile:FlxObject, Particle:FlxObject):Void
	{
		removeTile(cast Tile);
		_scoreBlue++;
		
	}
	
	private function rightHit(Tile:FlxObject, Particle:FlxObject):Void
	{
		removeTile(cast Tile);
		_scoreRed++;
	}
	
}