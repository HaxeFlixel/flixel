package flixel;

import flixel.group.FlxGroup;

/**
 * This is the basic game "state" object - e.g. in a simple game you might have a menu state and a play state.
 * It is for all intents and purpose a fancy FlxGroup. And really, it's not even that fancy.
 */
class FlxState extends FlxGroup
{
	/**
	* Determines whether or not this state is updated even when it is not the active state. For example, if you have your game state first, and then you push a menu state on top of it,
	* if this is set to true, the game state would continue to update in the background. By default this is false, so background states will be "paused" when they are not active.
	* @default false
	*/
	public var persistentUpdate:Bool = false;

	/**
	* Determines whether or not this state is updated even when it is not the active state. For example, if you have your game state first, and then you push a menu state on top of it, if this is set to true, the game state would continue to be drawn behind the pause state.
	* By default this is true, so background states will continue to be drawn behind the current state. If background states are not visible when you have a different state on top, you should set this to false for improved performance.
	* @default true
	*/
	public var persistentDraw:Bool = true;

	private var _subState:FlxSubState;
	/**
	 * Current substate.
	 * Substates also can have substates
	 */
	public var subState(get, null):FlxSubState;

	private inline function get_subState():FlxSubState
	{
		return _subState;
	}
	/**
	 * If a state change was requested, the new state object is stored here until we switch to it.
	 */
	public var requestedSubState:FlxSubState = null;

	/**
	 * Whether to reset the substate (when it changes, or when it's closed).
	 */
	public var requestSubStateReset:Bool = false;

	/**
	 * If substates get destroyed when they are closed, setting this to false might reduce state creation time, at greater memory cost.
	 */
	public var destroySubStates:Bool = true;
	
	public var bgColor(get, set):Int;

	private function get_bgColor():Int
	{
		return FlxG.cameras.bgColor;
	}

	private function set_bgColor(Value:Int):Int
	{
		return FlxG.cameras.bgColor = Value;
	}

	/**
	 * This function is called after the game engine successfully switches states. Override this function, NOT the constructor, to initialize or set up your game state.
	 * We do NOT recommend overriding the constructor, unless you want some crazy unpredictable things to happen!
	 */
	public function create():Void { }

	override public function draw():Void
	{
		if (persistentDraw || _subState == null)
		{
			super.draw();
		}
		
		if (_subState != null)
		{
			_subState.draw();
		}
	}

#if !FLX_NO_DEBUG
	override public function drawDebug():Void
	{
		if (persistentDraw || _subState == null)
		{
			super.drawDebug();
		}
		
		if (_subState != null)
		{
			_subState.drawDebug();
		}
	}
#end

	public function tryUpdate():Void
	{
		if (persistentUpdate || _subState == null)
		{
			update();
		}
		
		if (requestSubStateReset)
		{
			resetSubState();
			requestSubStateReset = false;
		}
		else if(_subState != null)
		{
			_subState.tryUpdate();
		}
	}

	/**
	 * Manually close the sub-state
	 */
	public inline function setSubState(subState:FlxSubState):Void
	{
		requestedSubState = subState;
		requestSubStateReset = true;
	}
	/**
	 * Manually close the sub-state
	 */
	public inline function closeSubState():Void
	{
		setSubState(null);
	}

	/**
	 * Load substate for this state
	 */
	public function resetSubState():Void
	{
		// Close the old state (if there is an old state)
		if(_subState != null)
		{
			if (_subState.closeCallback != null)
			{
				_subState.closeCallback();
			}
			if (destroySubStates)
			{
				_subState.destroy();
			}
		}
		
		// Assign the requested state (or set it to null)
		_subState = requestedSubState;
		
		if (_subState != null)
		{
			// I'm just copying the code from "FlxGame::switchState" which doesn't check for already craeted states. :/
			_subState._parentState = this;
			
			//Reset the input so things like "justPressed" won't interfere
			if (!persistentUpdate)
			{
				FlxG.inputs.reset();
			}
			
			if (!_subState.initialized)
			{
				_subState.initialize();
 				_subState.create();
			}
		}
	}

	override public function destroy():Void
	{
		if (_subState != null)
		{
			_subState.destroy();
			_subState = null;
		}
		super.destroy();
	}

	/**
	 * This method is called after application losts its focus.
	 * Can be useful if you using third part libraries, such as tweening engines.
	 */
	public function onFocusLost():Void { }

	/**
	 * This method is called after application gets focus.
	 * Can be useful if you using third part libraries, such as tweening engines.
	 */
	public function onFocus():Void { }

	/**
	 * This function is called whenever the window size has been changed.
	 * @param 	Width	The new window width
	 * @param 	Height	The new window Height
	 */  
	public function onResize(Width:Int, Height:Int):Void { }
}