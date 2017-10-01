package flixel;

import flixel.FlxCamera;
import flixel.util.FlxColor;

/**
 * A `FlxSubState` can be opened inside of a `FlxState`.
 * By default, it also stops the parent state from updating,
 * making it convenient for pause screens or menus.
 */
class FlxSubState extends FlxState
{
	/**
	 * Callback method for state open/resume event.
	 * @since 4.3.0
	 */
	public var openCallback:Void->Void;

	/**
	 * Callback method for state close event.
	 */
	public var closeCallback:Void->Void;
	
	/**
	 * Helper var for `close()` so `closeSubState()` can be called on the parent.
	 */
	@:noCompletion
	@:allow(flixel.FlxState.resetSubState)
	private var _parentState:FlxState;
	
	@:noCompletion
	private var _bgColor:FlxColor;

	@:noCompletion
	@:allow(flixel.FlxState.resetSubState)
	private var _created:Bool = false;
	
	/**
	 * @param   BGColor   background color for this substate
	 */
	public function new(BGColor:FlxColor = FlxColor.TRANSPARENT)
	{
		super();
		closeCallback = null;
		openCallback = null;
		
		bgColor = BGColor;
	}
	
	override public function draw():Void
	{
		//Draw background
		for (camera in cameras)
			camera.fill(bgColor);
		
		//Now draw all children
		super.draw();
	}
	
	override public function drawTo(Camera:FlxCamera):Void 
	{
		//Draw background
		Camera.fill(bgColor);
		//Now draw all children
		super.drawTo(Camera);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		closeCallback = null;
		openCallback = null;
		_parentState = null;
	}
	
	/**
	 * Closes this substate.
	 */
	public function close():Void
	{
		if (_parentState != null && _parentState.subState == this)
			_parentState.closeSubState();
	}
	
	@:noCompletion
	override private inline function get_bgColor():FlxColor
	{
		return _bgColor;
	}
	
	@:noCompletion
	override private function set_bgColor(Value:FlxColor):FlxColor
	{
		return _bgColor = Value;
	}
}