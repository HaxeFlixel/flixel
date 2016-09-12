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
	
	/**
	 * Helper sprite object for non-flash targets. Draws background
	 */
	@:noCompletion
	private var _bgSprite:FlxBGSprite;
	
	/**
	 * Helper var for close() so closeSubState() can be called on the parent.
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
	 * @param	BGColor		background color for this substate
	 */
	public function new(BGColor:FlxColor = FlxColor.TRANSPARENT)
	{
		super();
		closeCallback = null;
		
		if (FlxG.renderTile)
		{
			_bgSprite = new FlxBGSprite();
		}
		bgColor = BGColor;
	}
	
	override public function draw():Void
	{
		//Draw background
		if (FlxG.renderBlit)
		{
			for (camera in cameras)
			{
				camera.fill(bgColor);
			}
		}
		else
		{
			_bgSprite.draw();
		}
		
		//Now draw all children
		super.draw();
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		closeCallback = null;
		_parentState = null;
		_bgSprite = null;
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
	
	@:noCompletion
	override private inline function get_bgColor():FlxColor
	{
		return _bgColor;
	}
	
	@:noCompletion
	override private function set_bgColor(Value:FlxColor):FlxColor
	{
		if (FlxG.renderTile && _bgSprite != null)
			_bgSprite.pixels.setPixel32(0, 0, Value);
		
		return _bgColor = Value;
	}
}