package;

import flash.Lib;
import flixel.FlxGame;
import flixel.FlxG;
	
class GameClass extends FlxGame
{	
	public function new()
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		
		var ratioX:Float = stageWidth / 320;
		var ratioY:Float = stageHeight / 240;
		var ratio:Float = Math.min(ratioX, ratioY);
		
		var fps:Int = 60;
		
		super(Math.ceil(stageWidth / ratio), Math.ceil(stageHeight / ratio), MenuState, ratio, fps, fps);
		
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
	}
}