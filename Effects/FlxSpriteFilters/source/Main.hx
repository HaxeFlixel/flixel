package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flixel.FlxGame;

/**
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */

class Main extends Sprite 
{
	
	public function new() 
	{
		super();
		#if iphone
		Lib.current.stage.addEventListener(Event.RESIZE, init);
		#else
		addEventListener(Event.ADDED_TO_STAGE, init);
		#end
	}

	private function init(e) 
	{
		// import hxcpp lib.
			// add nmml def : <haxedef name="HXCPP_DEBUGGER" if="cpp" />
		var game:FiltersDemo = new FiltersDemo();
		addChild(game);
		//new hxcpp.DebugStdio(true);
		//FlxG.setDebuggerLayout(FlxG.DEBUGGER_BIG);
	}
	
	public static function main()
	{
		#if (flash9 || flash10)
			haxe.Log.trace = function(v,?pos) { untyped __global__["trace"](pos.className+"#"+pos.methodName+"("+pos.lineNumber+"):",v); }
		#end
		
		var stage = Lib.current.stage;
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.align = flash.display.StageAlign.TOP_LEFT;
		
		Lib.current.addChild(new Main());
	}
	
}
