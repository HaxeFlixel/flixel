package;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.Lib;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxCamera;
	
class GameClass extends FlxGame
{
	inline static private var GAME_WIDTH:Int = 320;
	inline static private var GAME_HEIGHT:Int = 240;
	
	/**
	 * Sets up our FlxGame class and loads into the MenuState.
	 */
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		
		var ratioX:Float = stageWidth / GAME_WIDTH;
		var ratioY:Float = stageHeight / GAME_HEIGHT;
		
		var ratio:Float = Math.min( ratioX, ratioY );
		
		var fps:Int = 60;
		
		super( Math.ceil( stageWidth / ratio ), Math.ceil( stageHeight / ratio ), MenuState, ratio, fps, fps );
		
		// Center game on screen.
		
		x = 0.5 * ( stageWidth - GAME_WIDTH * ratio );
		y = 0.5 * ( stageHeight - GAME_HEIGHT * ratio );
		
		// Load sounds for Android target.
		
		#if android
		FlxG.sound.add("build");
		FlxG.sound.add("deny");
		FlxG.sound.add("enemyhit");
		FlxG.sound.add("enemykill");
		FlxG.sound.add("gameover");
		FlxG.sound.add("hurt");
		FlxG.sound.add("select");
		FlxG.sound.add("shoot");
		FlxG.sound.add("td2");
		FlxG.sound.add("wavedefeated");
		#end
	}
	
	/**
	 * Override the base onResize function to center and stretch the game to fit the screen.
	 * Called on Ctrl+F for Flash, and Alt-Enter for Windows.
	 */
	override public function onResize( ?E:Event ):Void
	{
		// Set the FlxCamera's default zoom to one that will fill the screen but maintain the proper ratio.
		
		FlxCamera.defaultZoom = Math.min( Lib.current.stage.stageWidth / FlxG.width, Lib.current.stage.stageHeight / FlxG.height );
		
		// Set the main camera to the above default zoom, which is achieved by setting to zero.
		// Note that this would not work if we used our own camera, or multiple cameras!
		
		FlxG.camera.zoom = 0;
		
		// Lastly, center the game on the screen.
		
		x = ( Lib.current.stage.stageWidth - ( FlxG.width * FlxG.camera.zoom ) ) / 2;
		y = ( Lib.current.stage.stageHeight - ( FlxG.height * FlxG.camera.zoom ) ) / 2;
		
		super.onResize( E );
	}
}