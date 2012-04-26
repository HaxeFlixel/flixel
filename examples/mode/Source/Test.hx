package;

import nme.Assets;
import nme.display.BitmapData;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.display.FPS;
import nme.display.Sprite;
import nme.display.Tilesheet;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.Lib;
import nme.ui.Keyboard;
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