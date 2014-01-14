package;

import flash.Lib;
import flash.events.Event;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxCamera;

class GameClass extends FlxGame
{
	var gameWidth:Int = 160; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 90; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = PlayState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = false; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = true; // Whether to start the game in fullscreen on desktop targets
	
	/**
	 * You can pretty much ignore this logic and edit the variables above.
	 */
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		
		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
		
		super(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
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
