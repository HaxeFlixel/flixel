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
	 * Internal helper
	 */
	public var _parentState:FlxState;
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
	
	/**
	 * Internal helper for substates which can be reused
	 */
	private var _initialized:Bool = false;
	
	private var _bgColor:Int;
	
	public var initialized(get, null):Bool;
	
	private inline function get_initialized():Bool
	{ 
		return _initialized; 
	}
	
	/**
	 * Internal helper method
	 */
	public inline function initialize():Void
	{ 
		_initialized = true; 
	}
	
	/**
	 * Substate constructor
	 * @param	BGColor		background color for this substate
	 * @param	UseMouse	whether to show mouse pointer or not
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
	
	override public function draw():Void
	{
		//Draw background
		#if flash
		if(cameras == null) { cameras = FlxG.cameras.list; }
		var i:Int = 0;
		var l:Int = cameras.length;
		while (i < l)
		{
			var camera:FlxCamera = cameras[i++];
			camera.fill(this.bgColor);
		}
		#else
		_bgSprite.draw();
		#end
		
		//Now draw all children
		super.draw();
	}
	
	/**
	 * Use this method to close this substate
	 * @param	destroy	whether to destroy this state or leave it in memory
	 */
	public function close():Void
	{
		if (_parentState != null) 
		{ 
			_parentState.closeSubState(); 
		}
		#if !FLX_NO_DEBUG
		else 
		{ 
			// Missing parent from this state! Do something!!
			throw "This subState haven't any parent state";
		}
		#end
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		_initialized = false;
		_parentState = null;
		closeCallback = null;
	}
}