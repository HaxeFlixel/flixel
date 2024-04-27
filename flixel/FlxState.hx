package flixel;

import flixel.group.FlxContainer;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import flixel.util.typeLimit.NextState;

/**
 * This is the basic game "state" object - e.g. in a simple game you might have a menu state and a play state.
 * It is for all intents and purpose a fancy `FlxContainer`. And really, it's not even that fancy.
 */
@:keepSub // workaround for HaxeFoundation/haxe#3749
#if FLX_NO_UNIT_TEST
@:autoBuild(flixel.system.macros.FlxMacroUtil.deprecateOverride("switchTo", "switchTo is deprecated, use startOutro"))
#end
// show deprecation warning when `switchTo` is overriden in dereived classes
class FlxState extends FlxContainer
{
	/**
	 * Determines whether or not this state is updated even when it is not the active state.
	 * For example, if you have your game state first, and then you push a menu state on top of it,
	 * if this is set to `true`, the game state would continue to update in the background.
	 * By default this is `false`, so background states will be "paused" when they are not active.
	 */
	public var persistentUpdate:Bool = false;

	/**
	 * Determines whether or not this state is updated even when it is not the active state.
	 * For example, if you have your game state first, and then you push a menu state on top of it,
	 * if this is set to `true`, the game state would continue to be drawn behind the pause state.
	 * By default this is `true`, so background states will continue to be drawn behind the current state.
	 *
	 * If background states are not `visible` when you have a different state on top,
	 * you should set this to `false` for improved performance.
	 */
	public var persistentDraw:Bool = true;

	/**
	 * If substates get destroyed when they are closed, setting this to
	 * `false` might reduce state creation time, at greater memory cost.
	 */
	public var destroySubStates:Bool = true;

	/**
	 * The natural background color the cameras default to. In `AARRGGBB` format.
	 */
	public var bgColor(get, set):FlxColor;
	
	/**
	 * The specific argument that was passed into `switchState` or `FlxGame.new`
	 */
	@:allow(flixel.FlxGame)
	@:allow(flixel.FlxG)
	var _constructor:NextState;
	
	/**
	 * Current substate. `FlxSubState`s can also be nested.
	 */
	public var subState(default, null):FlxSubState;

	/**
	 * A `FlxSignal` that dispatches when a sub state is opened from this state.
	 * @since 4.9.0
	 */
	public var subStateOpened(default, null):FlxTypedSignal<FlxSubState->Void> = new FlxTypedSignal<FlxSubState->Void>();

	/**
	 * A `FlxSignal` that dispatches when a sub state is closed from this state.
	 * @since 4.9.0
	 */
	public var subStateClosed(default, null):FlxTypedSignal<FlxSubState->Void> = new FlxTypedSignal<FlxSubState->Void>();
	
	public function new():Void
	{
		super(0);
	}
	
	/**
	 * This function is called after the game engine successfully switches states.
	 * Override this function, NOT the constructor, to initialize or set up your game state.
	 * We do NOT recommend initializing any flixel objects or utilizing flixel features in
	 * the constructor, unless you want some crazy unpredictable things to happen!
	 */
	public function create():Void {}

	override function destroy():Void
	{
		_constructor = function():FlxState
		{
			throw "Attempting to resetState while the current state is destroyed";
		};

		FlxDestroyUtil.destroy(subStateOpened);
		
		FlxDestroyUtil.destroy(subStateClosed);
		
		if (subState != null)
		{
			subState.destroy();

			subState = null;
		}

		super.destroy();
	}

	/**
	 * Called from `FlxG.switchState()`. If `false` is returned, the state
	 * switch is cancelled - the default implementation returns `true`.
	 *
	 * Useful for customizing state switches, e.g. for transition effects.
	 */
	@:deprecated("switchTo is deprecated, use startOutro")
	public function switchTo(nextState:FlxState):Bool
	{
		return true;
	}
	
	/**
	 * Called from `FlxG.switchState()`, when `onOutroComplete` is called, the actual state
	 * switching will happen.
	 * 
	 * Note: Calling `super.startOutro(onOutroComplete)` will call `onOutroComplete`.
	 * 
	 * @param   onOutroComplete  Called when the outro is complete.
	 * @since 5.3.0
	 */
	public function startOutro(onOutroComplete:()->Void)
	{
		onOutroComplete();
	}

	/**
	 * This method is called after the game loses focus.
	 * Can be useful for third party libraries, such as tweening engines.
	 */
	public function onFocusLost():Void {}

	/**
	 * This method is called after the game receives focus.
	 * Can be useful for third party libraries, such as tweening engines.
	 */
	public function onFocus():Void {}

	/**
	 * This function is called whenever the window is resized.
	 *
	 * @param   width    The new window width
	 * @param   height   The new window height
	 */
	public function onResize(width:Int, height:Int):Void {}

	public function openSubState(_subState:FlxSubState):Void
	{
		if (subState != null)
			closeSubState();

		if (_subState == null)
			throw "Cannot open a `null` `FlxSubState`.";

		subState = _subState;

		if (!persistentUpdate)
			FlxG.inputs.onStateSwitch();

		subState.parentState = this;

		subState.create();

		if (subState.openCallback != null)
			subState.openCallback();

		if (subStateOpened != null)
			subStateOpened.dispatch(subState);
	}

	public function closeSubState():Void
	{
		if (subState.closeCallback != null)
			subState.closeCallback();

		if (subStateClosed != null)
			subStateClosed.dispatch(subState);

		if (destroySubStates)
			subState.destroy();

		subState = null;
	}

	@:noCompletion
	function get_bgColor():FlxColor
	{
		return FlxG.cameras.bgColor;
	}

	@:noCompletion
	function set_bgColor(Value:FlxColor):FlxColor
	{
		return FlxG.cameras.bgColor = Value;
	}
}
