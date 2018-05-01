package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import openfl.Assets;

class PlayState extends FlxState
{
	/**
	 * We use these to tell which mode we are at, recording or replaying
	 */
	static var recording:Bool = false;
	static var replaying:Bool = false;
	
	/**
	 * Some intructions
	 */
	var _hintText:FlxText;
	/**
	 * Just a simple tilemap
	 */
	var _tilemap:FlxTilemap;
	/**
	 * The blue block player controls
	 */
	var _player:FlxSprite;
	/**
	 * The red block represents mouse
	 */
	var _cursor:FlxSprite;
	
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		// Set up the TILEMAP
		_tilemap = new FlxTilemap();
		_tilemap.loadMapFromCSV("assets/simpleMap.csv", "assets/tiles.png", 25, 25, AUTO);
		add(_tilemap);
		_tilemap.y -= 15;
		
		//Set up the cursor
		_cursor = new FlxSprite();
		_cursor.makeGraphic(6, 6, FlxColor.RED);
		add(_cursor);
		
		// Set up the Player
		_player = new FlxSprite(30, 200);
		_player.makeGraphic(12, 12, 0xFF8CF1FF);
		// Theses are pysics settings, controling how the players behave in the game
		_player.maxVelocity.set(150, 350);
		_player.acceleration.y = 350;
		_player.drag.x = _player.maxVelocity.x * 4;
		add(_player);
		
		// Set up UI
		_hintText =  new FlxText(0, 268, 400);
		_hintText.setFormat(null, 12, FlxColor.BLACK, CENTER);
		add(_hintText);
		
		// Adjust things according to different modes
		init();
		
		super.create();
	}
	
	override public function update(elapsed:Float):Void
	{
		FlxG.collide(_tilemap, _player);
		
		// Update the player
		_player.acceleration.x = 0;
		
		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			_player.acceleration.x -= _player.drag.x;
		}
		else if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			_player.acceleration.x += _player.drag.x;
		}
		if (FlxG.keys.anyJustPressed([UP, W]) && (_player.velocity.y == 0))
		{
			_player.velocity.y = -200;
		}
		
		if (!recording && !replaying)
		{
			startRecording();
		}
		
		/**
		 * Notice that I add "&& recording", because recording will recording every input
		 * so R key for replay will also be recorded and be triggered at replaying
		 * Please pay attention to the inputs that are not supposed to be recorded
		 */
		if (FlxG.keys.justPressed.R && recording)
		{
			loadReplay();
		}
		
		// Update the red block cursor
		_cursor.scale.set(1, 1);
		
		if (FlxG.mouse.pressed) 
		{
			_cursor.scale.set(2, 2);
		}
		_cursor.x = FlxG.mouse.screenX;
		_cursor.y = FlxG.mouse.screenY;
		
		super.update(elapsed);
	}
	
	/**
	 * I use this funtion to do the init differs from recording to replaying
	 */
	function init():Void
	{
		if (recording) 
		{
			_player.alpha = 1;
			_cursor.alpha = 1;
			_hintText.text = "Recording: Arrow Keys : move, R : replay\nMouse move and click will also be recorded";
		}
		else if (replaying) 
		{
			_player.alpha = 0.5;
			_cursor.alpha = 0.5;
			_hintText.text = "Replaying: Press any key or mouse button to stop and record again";
		}
	}
	
	function startRecording():Void 
	{
		recording = true;
		replaying = false;
		
		/**
		 * Note FlxG.recordReplay will restart the game or state
		 * This function will trigger a flag in FlxGame
		 * and let the internal FlxReplay to record input on every frame
		 */
		FlxG.vcr.startRecording(false);
	}
	
	function loadReplay():Void 
	{
		replaying = true;
		recording = false;
		
		/**
		 * Here we get a string from stopRecoding()
		 * which records all the input during recording
		 * Then we load the save
		 */
		var save:String = FlxG.vcr.stopRecording(false);
		FlxG.vcr.loadReplay(save, new PlayState(), ["ANY", "MOUSE"], 0, startRecording);
	}
}