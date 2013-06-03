package;

import openfl.Assets;
import flash.display.BitmapData;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import openfl.display.FPS;
import flash.display.Sprite;
import openfl.display.Tilesheet;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flash.ui.Keyboard;
import org.flixel.FlxGame;

/**
 * @author Joshua Granick
 */
class Test extends Sprite 
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
		
		var demo:FlxGame = new Mode();
		addChild(demo);
		
		var fps:FPS = new FPS();
		addChild(fps);
		fps.x = 20;
		fps.y = 20;
		fps.textColor = 0xffffff;
		
		#if (cpp || neko)
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUP);
		#end
	}
	
	#if (cpp || neko)
	private function onKeyUP(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.ESCAPE)
		{
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
	public static function main() {
		
		Lib.current.addChild(new Test());
	}
	
}