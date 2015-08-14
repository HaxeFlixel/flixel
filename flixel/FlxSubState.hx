package flixel;

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
		
		// TODO: draw background...
		
		#end
		
		//Now draw all children
		super.draw();
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		closeCallback = null;
		_parentState = null;
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
		return _bgColor = Value;
	}
}