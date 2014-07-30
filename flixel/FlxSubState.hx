package flixel;

import flixel.system.FlxBGSprite;
import flixel.util.FlxColor;

/**
 * This is the basic game "state" object - e.g. in a simple game you might have a menu state and a play state.
 * It is for all intents and purpose a fancy FlxGroup. And really, it's not even that fancy.
 */
@:allow(flixel.FlxState)
class FlxSubState extends FlxState
{
	/**
	 * Callback method for state close event
	 */
	public var closeCallback:Void->Void;
	
	#if FLX_RENDER_TILE
	/**
	 * Helper sprite object for non-flash targets. Draws background
	 */
	private var _bgSprite:FlxBGSprite;
	#end
	
	/**
	 * Helper var for close() so closeSubState() can be called on the parent.
	 */ 
	private var _parentState:FlxState;
	
	private var _bgColor:FlxColor;
 
	private var _created:Bool = false;
	
	/**
	 * @param	BGColor		background color for this substate
	 */
	public function new(BGColor:FlxColor = 0)
	{
		super();
		closeCallback = null;
		
		#if FLX_RENDER_TILE
		_bgSprite = new FlxBGSprite();
		#end
		bgColor = BGColor;
	}
	
	override public function draw():Void
	{
		//Draw background
		#if FLX_RENDER_BLIT
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
		_parentState = null;
		#if FLX_RENDER_TILE
		_bgSprite = null;
		#end
	}
	
	/**
	 * Closes this substate.
	 */ 
	public function close():Void
	{
		if (_parentState != null && _parentState.subState == this) 
		{ 
			_parentState.closeSubState(); 
		}
	}
	
	override private inline function get_bgColor():Int
	{
		return _bgColor;
	}
	
	override private function set_bgColor(Value:Int):Int
	{
		#if FLX_RENDER_TILE
		if (_bgSprite != null)
		{
			_bgSprite.pixels.setPixel32(0, 0, Value);
		}
		#end
		
		return _bgColor = Value;
	}
}