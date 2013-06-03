package;

import flash.ui.Mouse;
import openfl.Assets;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxTilemap;
import org.flixel.system.FlxReplay;

class PlayState extends FlxState
{
	private var hintText:FlxText;

	private var simpleTilemap:FlxTilemap;
	
	/**
	 * the blue block player controls
	 */
	private var thePlayer:FlxSprite;
	
	/**
	 * the red block represents mouse
	 */
	private var theCursor:FlxSprite;
	
	/*
	 * We use these to tell which mode we are at, recording or replaying
	 */
	//private static var recording:Bool;
	//private static var replaying:Bool;
	
	public function new()
	{
		//recording = false;
		//replaying = false;
		
		super();
	}
	
	override public function create():Void
	{
		FlxG.framerate = 60;
		FlxG.flashFramerate = 60;
		FlxG.mouse.hide();
		
		//Set up the TILEMAP
		simpleTilemap = new FlxTilemap();
		simpleTilemap.loadMap(Assets.getText("assets/simpleMap.csv"), "assets/tiles.png", 25, 25, FlxTilemap.AUTO);
		add(simpleTilemap);
		simpleTilemap.y -= 15;
		
		//Set up the cursor
		theCursor = new FlxSprite().makeGraphic(6, 6, 0xFFFF0000);
		add(theCursor);
		
		//Set up the Player
		thePlayer = new FlxSprite().makeGraphic(12, 12, 0xFF8CF1FF);
		thePlayer.maxVelocity.x = 80;   // Theses are pysics settings,
		thePlayer.maxVelocity.y = 200;  // controling how the players behave
		thePlayer.acceleration.y = 300; // in the game
		thePlayer.drag.x = thePlayer.maxVelocity.x * 4;
		thePlayer.x = 30;
		thePlayer.y = 200;
		add(thePlayer);
		
		//Set up UI
		hintText =  new FlxText(0, 268, 400);
		hintText.color = 0xFF000000;
		hintText.size = 12;
		add(hintText);
		
		//adjust things according to different modes
		init();
		
		super.create();
	}
	
	override public function update():Void
	{
		FlxG.collide(simpleTilemap, thePlayer);
		
		//Update the player
		thePlayer.acceleration.x = 0;
		if(FlxG.keys.LEFT)
		{
			thePlayer.acceleration.x -= thePlayer.drag.x;
		}
		else if(FlxG.keys.RIGHT)
		{
			thePlayer.acceleration.x += thePlayer.drag.x;
		}
		if(FlxG.keys.justPressed("X") && thePlayer.velocity.y == 0)
		{
			thePlayer.velocity.y = -200;
		}
		
		if (!StateManager.recording && !StateManager.replaying)
		{
			start_record();
		}
		
		/**
		 * Notice that I add "&&recording", because recording will recording every input
		 * so R key for replay will also be recorded and
		 * be triggered at replaying
		 * Please pay attention to the inputs that are not supposed to be recorded
		 */
		if (FlxG.keys.justPressed("R") && StateManager.recording)
		{
			start_play();
		}
		
		
		//Update the red block cursor
		theCursor.scale = new FlxPoint(1, 1);
		if (FlxG.mouse.pressed()) 
		{
			theCursor.scale = new FlxPoint(2, 2);
		}
		theCursor.x = FlxG.mouse.screenX;
		theCursor.y = FlxG.mouse.screenY;
		
		super.update();
	}
	
	/**
	 * I use this funtion to do the init differs from recording to replaying
	 */
	private function init():Void
	{
		if (StateManager.recording) 
		{
			thePlayer.alpha = 1;
			theCursor.alpha = 1;
			hintText.text = "Recording: Arrow Keys : move, X : jump, R : replay\nMouse move and click will also be recorded";
		}
		else if (StateManager.replaying) 
		{
			thePlayer.alpha = 0.5;
			theCursor.alpha = 0.5;
			hintText.text = "Replaying: Press any key or mouse button to stop and record again";
		}
	}
	
	private function start_record():Void 
	{
		StateManager.recording = true;
		StateManager.replaying = false;
		
		/*
		 *Note FlxG.recordReplay will restart the game or state
		 *This function will trigger a flag in FlxGame
		 *and let the internal FlxReplay to record input on every frame
		 */
		FlxG.recordReplay(false);
	}
	
	private function start_play():Void 
	{
		StateManager.replaying = true;
		StateManager.recording = false;
		
		/*
		 * Here we get a string from stopRecoding()
		 * which records all the input during recording
		 * Then we load the save
		 */
		
		var save:String = FlxG.stopRecording();
		
		/**
		 * NOTE "ANY" or other key wont work under debug mode!
		 */
		FlxG.loadReplay(save, new PlayState(), ["ANY", "MOUSE"], 0, start_record);
		
	}
}