package flixel;

import flixel.system.FlxBGSprite;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

/**
 * A `FlxSubState` can be opened inside of a `FlxState`.
 * By default, it also stops the parent state from updating,
 * making it convenient for pause screens or menus.
 * 
 * @see [FlxSubstate snippet](https://snippets.haxeflixel.com/states/flxsubstate/)
 * @see [Substate demo](https://haxeflixel.com/demos/SubState/)
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
	 * Helper sprite object for non-flash targets. Draws the background.
	 */
	@:noCompletion
	var _bgSprite:FlxBGSprite;

	@:noCompletion
	var _bgColor:FlxColor;

	/**
	 * Stores a reference to the origin of `this` `FlxSubState`.
	 */
	@:allow(flixel.FlxState.openSubState)
	public var parentState(default, null):FlxState;

	@:deprecated("`FlxSubState._parentState` is deprecated, use `FlxSubState.parentState instead.")
	var _parentState(get, never):FlxState;

	/**
	 * @param   BGColor   background color for this substate
	 */
	public function new(BGColor:FlxColor = FlxColor.TRANSPARENT)
	{
		super();
		closeCallback = null;
		openCallback = null;

		if (FlxG.renderTile)
			_bgSprite = new FlxBGSprite();

		bgColor = BGColor;
	}

	override public function draw():Void
	{
		// Draw background
		if (FlxG.renderBlit)
		{
			for (camera in getCamerasLegacy())
			{
				camera.fill(bgColor);
			}
		}
		else
		{
			_bgSprite.draw();
		}

		// Now draw all children
		super.draw();
	}

	override public function destroy():Void
	{
		super.destroy();

		closeCallback = null;
		openCallback = null;

		parentState = null;

		_bgSprite = FlxDestroyUtil.destroy(_bgSprite);
	}

	/**
	 * Closes `this` `FlxSubState`.
	 */
	public function close():Void
	{
		if (parentState != null && parentState.subState == this)
			parentState.closeSubState();
	}

	@:noCompletion
	override inline function get_bgColor():FlxColor
	{
		return _bgColor;
	}

	@:noCompletion
	override function set_bgColor(Value:FlxColor):FlxColor
	{
		if (FlxG.renderTile && _bgSprite != null)
			_bgSprite.pixels.setPixel32(0, 0, Value);

		return _bgColor = Value;
	}
	
	@:noCompletion
	function get__parentState():FlxState
	{
		return parentState;
	}
}
