package flixel;

import flixel.system.FlxBGSprite;
import flixel.util.FlxColor;

/**
 * This is the basic game "state" object - e.g. in a simple game you might have a menu state and a play state.
 * It is for all intents and purpose a fancy FlxGroup. And really, it's not even that fancy.
 */
class FlxSubState extends FlxState
{
	/**
	 * Callback method for state close event
	 */
	public var closeCallback:Void->Void;
	
	#if !flash
	/**
	 * Helper sprite object for non-flash targets. Draws background
	 */
	private var _bgSprite:FlxBGSprite;
	#end
	
	private var _bgColor:Int;
	
	/**
	 * Helper var for the parent state to determine whether to call create() or not. 
	 */  
	@:allow(flixel.FlxState)
	private var _initialized:Bool = false;
	
	/**
	 * @param	BGColor		background color for this substate
	 */
	public function new(BGColor:Int = FlxColor.TRANSPARENT)
	{
		super();
		closeCallback = null;
		
		#if !flash
		_bgSprite = new FlxBGSprite();
		#end
		bgColor = BGColor;
	}
	
	override public function draw():Void
	{
		//Draw background
		#if flash
		if (cameras == null) 
		{ 
			cameras = FlxG.cameras.list; 
		}
		
		for (camera in cameras)
		{
			camera.fill(bgColor);
		}
		#else
		_bgSprite.draw();
		#end
		
		//Now draw all children
		super.draw();
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		closeCallback = null;
		#if !flash
		_bgSprite = null;
		#end
	}
	
	override private inline function get_bgColor():Int
	{
		return _bgColor;
	}
	
	override private function set_bgColor(Value:Int):Int
	{
		#if !flash
		if (_bgSprite != null)
		{
			_bgSprite.pixels.setPixel32(0, 0, Value);
		}
		#end
		
		return _bgColor = Value;
	}
}