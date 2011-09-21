package;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

/**
 * ...
 * @author Zaphod
 */

class Main extends Sprite
{
	
	static function main() 
	{
		flash.Lib.current.addChild(new Main());
	}
	
	public function new() 
	{
		super();
		
		if (stage != null) init();
		else addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event = null):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		// entry point
		flash.Lib.current.addChild(new ParticlesDemo());
		
	}
	
}