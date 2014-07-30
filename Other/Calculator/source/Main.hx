package;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flixel.FlxGame;

class GameClass extends FlxGame
{	
	public function new()
	{
		var stageWidth:Int = 640;
		var stageHeight:Int = 480;
		var ratioX:Float = stageWidth / 320;
		var ratioY:Float = stageHeight / 240;
		var ratio:Float = Math.min(ratioX, ratioY);
		var fps:Int = 60;
		
		super(Math.ceil(stageWidth / ratio), Math.ceil(stageHeight / ratio), State, ratio, fps, fps, true);
	}
}

class Main extends Sprite 
{
	public static function main():Void
	{	
		Lib.current.addChild(new Main());
	}
	
	public function new() 
	{
		super();
		
		if (stage != null) 
			init();
			
		else 
			addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(?E:Event):Void 
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);
		
		initialize();
		
		var game:FlxGame = new GameClass();
		addChild(game);
	}
	
	private function initialize():Void 
	{
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
	}
}