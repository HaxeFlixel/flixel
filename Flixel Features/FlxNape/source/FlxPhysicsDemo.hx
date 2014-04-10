package;

import flash.Lib;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.system.FlxSplash;
import FlxPhysicsDemo;
import states.Balloons;
import states.Blob;
import states.Cutup;
import states.Fight;
import states.Piramid;

/**
 * Demo for HaxeFlixel nape physics.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 * @link https://github.com/ProG4mr
 */

class FlxPhysicsDemo extends FlxGame
{
	private static var currentState:Int = 0;
	
	public function new() 
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		
		var ratioX:Float = stageWidth / 640;
		var ratioY:Float = stageHeight / 480;
		var ratio:Float = Math.min(ratioX, ratioY);
		
		// we're in debug mode because we need the debug drawing, but let's play the splash anyway!
		FlxSplash.nextState = Piramid;
		#if (flash || desktop || neko)
		super(Math.floor(stageWidth / ratio) , Math.floor(stageHeight / ratio), FlxSplash, ratio, 60, 60);
		#else
		super(Math.floor(stageWidth / ratio), Math.floor(stageHeight / ratio), FlxSplash, ratio, 60, 30);
		#end
		
	}
	
	public static function nextState()
	{
		currentState++;
		currentState %= 5;
		changeState();
	}
	
	public static function prevState()
	{
		currentState--;
		currentState < 0 ? currentState = 4 : null;
		changeState();
	}
	
	private static function changeState()
	{
		trace("current state " + currentState);
		switch (currentState)
		{
			case 0:	FlxG.switchState(new Piramid());
			case 1: FlxG.switchState(new Balloons());
			case 2: FlxG.switchState(new Blob());
			case 3: FlxG.switchState(new Fight());
			case 4: FlxG.switchState(new Cutup());
			//case 1: FlxG.switchState(new Balls());
			//case 2: FlxG.switchState(new SolarSystem());
			//case 3: FlxG.switchState(new Explosions());
		}
	}

}