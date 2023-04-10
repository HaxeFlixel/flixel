package flixel;

import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal.FlxTypedSignal;

/**
 * This is the basic game "state" object - e.g. in a simple game you might have a menu state and a play state.
 * It is for all intents and purpose a fancy `FlxGroup`. And really, it's not even that fancy.
 */
@:keepSub // workaround for HaxeFoundation/haxe#3749
@:autoBuild(flixel.system.macros.FlxMacroUtil.deprecateOverride("switchTo", "switchTo is deprecated, use startOutro"))
// show deprecation warning when `switchTo` is overriden in dereived classes
class FlxState extends FlxGroup
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
	 * Current substate. Substates also can be nested.
	 */
	public var subState(default, null):FlxSubState;

	/**
	 * If a state change was requested, the new state object is stored here until we switch to it.
	 */
	@:noCompletion
	var _requestedSubState:FlxSubState;

	/**
	 * Whether to reset the substate (when it changes, or when it's closed).
	 */
	@:noCompletion
	var _requestSubStateReset:Bool = false;

	/**
	 * A `FlxSignal` that dispatches when a sub state is opened from this state.
	 * @since 4.9.0
	 */
	public var subStateOpened(get, never):FlxTypedSignal<FlxSubState->Void>;

	/**
	 * A `FlxSignal` that dispatches when a sub state is closed from this state.
	 * @since 4.9.0
	 */
	public var subStateClosed(get, never):FlxTypedSignal<FlxSubState->Void>;

	/**
	 * Internal variables for lazily creating `subStateOpened` and `subStateClosed` signals when needed.
	 */
	@:noCompletion
	var _subStateOpened:FlxTypedSignal<FlxSubState->Void>;

	@:noCompletion
	var _subStateClosed:FlxTypedSignal<FlxSubState->Void>;
    
	/**
	 * This function is called after the game engine successfully switches states.
	 * Override this function, NOT the constructor, to initialize or set up your game state.
	 * We do NOT recommend initializing any flixel objects or utilizing flixel features in
	 * the constructor, unless you want some crazy unpredictable things to happen!
	 */
	public function create():Void {}

	override public function draw():Void
	{
		if (persistentDraw || subState == null)
			super.draw();

		if (subState != null)
			subState.draw();
	}

	public function openSubState(SubState:FlxSubState):Void
	{
		_requestSubStateReset = true;
		_requestedSubState = SubState;
	}

	/**
	 * Closes the substate of this state, if one exists.
	 */
	public function closeSubState():Void
	{
		_requestSubStateReset = true;
	}

	/**
	 * Load substate for this state
	 */
	public function resetSubState():Void
	{
		// Close the old state (if there is an old state)
		if (subState != null)
		{
			if (subState.closeCallback != null)
				subState.closeCallback();
			if (_subStateClosed != null)
				_subStateClosed.dispatch(subState);

			if (destroySubStates)
				subState.destroy();
		}

		// Assign the requested state (or set it to null)
		subState = _requestedSubState;
		_requestedSubState = null;

		if (subState != null)
		{
			// Reset the input so things like "justPressed" won't interfere
			if (!persistentUpdate)
				FlxG.inputs.onStateSwitch();

			subState._parentState = this;

			if (!subState._created)
			{
				subState._created = true;
				subState.create();
			}
			if (subState.openCallback != null)
				subState.openCallback();
			if (_subStateOpened != null)
				_subStateOpened.dispatch(subState);
		}
	}

	override public function destroy():Void
	{
		FlxDestroyUtil.destroy(_subStateOpened);
		FlxDestroyUtil.destroy(_subStateClosed);
        
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
	 * This function is called whenever the window size has been changed.
	 *
	 * @param   Width    The new window width
	 * @param   Height   The new window Height
	 */
	public function onResize(Width:Int, Height:Int):Void {}

	@:allow(flixel.FlxGame)
	function tryUpdate(elapsed:Float):Void
	{
		if (persistentUpdate || subState == null)
			update(elapsed);

		if (_requestSubStateReset)
		{
			_requestSubStateReset = false;
			resetSubState();
		}
		if (subState != null)
		{
			subState.tryUpdate(elapsed);
		}
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
    
	@:noCompletion
	function get_subStateOpened():FlxTypedSignal<FlxSubState->Void>
	{
		if (_subStateOpened == null)
			_subStateOpened = new FlxTypedSignal<FlxSubState->Void>();

		return _subStateOpened;
	}

	@:noCompletion
	function get_subStateClosed():FlxTypedSignal<FlxSubState->Void>
	{
		if (_subStateClosed == null)
			_subStateClosed = new FlxTypedSignal<FlxSubState->Void>();

		return _subStateClosed;
	}
}
