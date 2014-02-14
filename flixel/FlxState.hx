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
	*/
	public var persistentUpdate:Bool = false;

	/**
	* Determines whether or not this state is updated even when it is not the active state. For example, if you have your game state first, and then you push a menu state on top of it, if this is set to true, the game state would continue to be drawn behind the pause state.
	* By default this is true, so background states will continue to be drawn behind the current state. If background states are not visible when you have a different state on top, you should set this to false for improved performance.
	*/
	public var persistentDraw:Bool = true;

	/**
	 * If substates get destroyed when they are closed, setting this to false might reduce state creation time, at greater memory cost.
	 */
	public var destroySubStates:Bool = true;
	
	public var bgColor(get, set):Int;
	
	/**
	 * Current substate. Substates also can be nested.
	 */
	public var subState(default, null):FlxSubState;
	
	/**
	 * If a state change was requested, the new state object is stored here until we switch to it.
	 */
	private var _requestedSubState:FlxSubState;

	/**
	 * Whether to reset the substate (when it changes, or when it's closed).
	 */
	private var _requestSubStateReset:Bool = false;

	/**
	 * This function is called after the game engine successfully switches states. Override this function, NOT the constructor, to initialize or set up your game state.
	 * We do NOT recommend overriding the constructor, unless you want some crazy unpredictable things to happen!
	 */
	public function create():Void {}

	override public function draw():Void
	{
		if (persistentDraw || subState == null)
		{
			super.draw();
		}
		
		if (subState != null)
		{
			subState.draw();
		}
	}

	#if !FLX_NO_DEBUG
	override public function drawDebug():Void
	{
		if (persistentDraw || subState == null)
		{
			super.drawDebug();
		}
		
		if (subState != null)
		{
			subState.drawDebug();
		}
	}
	#end
	
	public inline function openSubState(SubState:FlxSubState):Void
	{
		_requestSubStateReset = true;
		_requestedSubState = SubState;
	}
	
	/**
	 * Closes the substate of this state, if one exists.
	 */
	public inline function closeSubState():Void
	{
		_requestSubStateReset = true;
		_requestedSubState = null;
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
			{
				subState.closeCallback();
			}
			if (destroySubStates)
			{
				subState.destroy();
			}
		}
		
		// Assign the requested state (or set it to null)
		subState = _requestedSubState;
		
		if (subState != null)
		{
			//Reset the input so things like "justPressed" won't interfere
			if (!persistentUpdate)
			{
				FlxG.inputs.reset();
			}
			
			if (!subState._created)
			{
				subState._created = true;
				subState._parentState = this;
 				subState.create();
			}
		}
	}

	override public function destroy():Void
	{
		if (subState != null)
		{
			subState.destroy();
			subState = null;
		}
		super.destroy();
	}

	/**
	 * This method is called after application losts its focus.
	 * Can be useful if you using third part libraries, such as tweening engines.
	 */
	public function onFocusLost():Void {}

	/**
	 * This method is called after application gets focus.
	 * Can be useful if you using third part libraries, such as tweening engines.
	 */
	public function onFocus():Void {}

	/**
	 * This function is called whenever the window size has been changed.
	 * 
	 * @param 	Width	The new window width
	 * @param 	Height	The new window Height
	 */  
	public function onResize(Width:Int, Height:Int):Void {}
	
	@:allow(flixel.FlxGame)
	private function tryUpdate():Void
	{
		if (persistentUpdate || (subState == null))
		{
			update();
		}
		
		if (_requestSubStateReset)
		{
			resetSubState();
			_requestSubStateReset = false;
		}
		else if (subState != null)
		{
			subState.tryUpdate();
		}
	}
	
	private function get_bgColor():Int
	{
		return FlxG.cameras.bgColor;
	}

	private function set_bgColor(Value:Int):Int
	{
		return FlxG.cameras.bgColor = Value;
	}
}