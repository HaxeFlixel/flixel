package;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import flixel.FlxGame;

class Main extends Sprite 
{
	static public function main():Void
	{	
		Lib.current.addChild(new Main());
	}
	
	public function new() 
	{
		super();
		
		if (stage != null) 
		{
			init();
		}
		else 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}
	
	private function init(?E:Event):Void 
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		addChild(new FlxGame(640, 480, PlayState));
	}
}