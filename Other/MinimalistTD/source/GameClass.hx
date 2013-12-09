package;

import flash.Lib;
import flixel.FlxG;
import flixel.FlxGame;
	
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
		
		this.x = 0.5 * (stageWidth - 320 * ratio);
		this.y = 0.5 * (stageHeight - 240 * ratio);
		
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
}