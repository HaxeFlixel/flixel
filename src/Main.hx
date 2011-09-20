package;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import org.flixel.FlxSprite;
import org.flixel.plugin.photonstorm.baseTypes.MouseSpring;
import org.flixel.plugin.photonstorm.FlxControl;
import org.flixel.plugin.photonstorm.FlxControlHandler;
import org.flixel.plugin.photonstorm.FlxDelay;
import org.flixel.plugin.photonstorm.FlxDisplay;
import org.flixel.plugin.photonstorm.FlxExplode;
import org.flixel.plugin.photonstorm.FlxExtendedSprite;
import org.flixel.plugin.photonstorm.FlxGridOverlay;
import org.flixel.plugin.photonstorm.FlxLinkedGroup;
import org.flixel.plugin.photonstorm.FlxMath;
import org.flixel.plugin.photonstorm.FlxVelocity;

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
		//flash.Lib.current.addChild(new ParticlesDemo());
		trace(FlxMath.rand());
		
		var spr:FlxSprite = new FlxSprite();
		var grp:FlxLinkedGroup = new FlxLinkedGroup();
		grp.add(spr);
		var expl:FlxExplode = new FlxExplode();
		var delay:FlxDelay = new FlxDelay(500);
		flash.Lib.current.addChild(delay);
		delay.callbackFunction = onDelay;
		delay.start();
		
		var disp:FlxDisplay = new FlxDisplay();
		var vel:FlxVelocity = new FlxVelocity();
		
		var mouseSpring:MouseSpring = new MouseSpring(new FlxExtendedSprite());
		//var extSpr:FlxExtendedSprite = new FlxExtendedSprite();
		var ctrlHandler:FlxControlHandler = new FlxControlHandler(new FlxSprite(), FlxControlHandler.MOVEMENT_INSTANT, FlxControlHandler.STOPPING_INSTANT);
		var flxCtrl:FlxControl = new FlxControl();
		var flxGrid:FlxGridOverlay = new FlxGridOverlay();
	}
	
	public function onDelay():Void
	{
		trace("On delay");
	}
	
}