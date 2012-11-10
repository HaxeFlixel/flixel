package;

import nme.Lib;
import org.flixel.FlxG;
import org.flixel.FlxGame;
	
class Mode extends FlxGame
{
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		var ratioX:Float = stageWidth / 320;
		var ratioY:Float = stageHeight / 240;
		var ratio:Float = Math.min(ratioX, ratioY);
		//var ratio:Float = 1;
		#if (flash || desktop || neko)
		super(Math.floor(stageWidth / ratio), Math.floor(stageHeight / ratio), MenuState, ratio, 60, 60);
		#else
		super(Math.floor(stageWidth / ratio), Math.floor(stageHeight / ratio), MenuState, ratio, 60, 30);
		#end
		
		#if android
		FlxG.addSound("Beep");
		FlxG.addSound("Asplode");
		FlxG.addSound("Button");
		FlxG.addSound("Countdown");
		FlxG.addSound("Enemy");
		FlxG.addSound("Hit");
		FlxG.addSound("Hurt");
		FlxG.addSound("Jam");
		FlxG.addSound("Jet");
		FlxG.addSound("Jump");
		FlxG.addSound("Land");
		FlxG.addSound("MenuHit");
		FlxG.addSound("MenuHit2");
		FlxG.addSound("Shoot");
		#end
		
	//	forceDebugger = true;
	}
}
