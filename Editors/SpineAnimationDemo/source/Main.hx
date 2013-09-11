package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.ui.Keyboard;
import flixel.FlxGame;
 
/**
 * sbatista
 * @author 
 */

class Main extends Sprite 
{
	
	public function new () 
	{
		super();
		
		if (stage != null) 
			init();
		else 
			addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(?e:Event = null):Void 
	{
		if (hasEventListener(Event.ADDED_TO_STAGE)) 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		initialize();
		
		var game:FlxGame = new ProjectClass();
		addChild(game);
		
		#if (cpp || neko)
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUP);
		#end
		
		// Profile code - disable <haxedef name="profile_cpp" if="target_cpp" /> before ship
		#if (profile_cpp && !neko)
		cpp.vm.Profiler.start("perf.txt");
		#end
	}
	
	#if (cpp || neko)
	private function onKeyUP(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.ESCAPE) 
		{
			// Profiling code - disable <haxedef name="profile_cpp" if="target_cpp" /> before ship
			#if (profile_cpp && !neko)
			cpp.vm.Profiler.stop();
			#end
			
			Lib.exit();
		}
	}
	#end
	
	private function initialize():Void 
	{
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
	}
	
	// Entry point
	public static function main() 
	{
		Lib.current.addChild(new Main());
	}
	
}