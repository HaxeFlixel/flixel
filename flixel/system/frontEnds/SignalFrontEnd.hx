package flixel.system.frontEnds;

import flixel.util.FlxSignal;

/**
 * Accessed via `FlxG.signals`.
 */
class SignalFrontEnd
{
	/**
	 * Gets dispatched when a state change occurs.
	 * @since 4.6.0
	 */
	public var preStateSwitch(default, null):FlxSignal = new FlxSignal();

	/**
	 * @since 4.6.0
	 */
	public var postStateSwitch(default, null):FlxSignal = new FlxSignal();

	@:deprecated("Use preStateSwitch instead of stateSwitched")
	public var stateSwitched(get, never):FlxSignal;
	public var preStateCreate(default, null):FlxTypedSignal<FlxState->Void> = new FlxTypedSignal<FlxState->Void>();

	/**
	 * Gets dispatched when the game is resized.
	 * Passes the new window width and height to callback functions.
	 */
	public var gameResized(default, null):FlxTypedSignal<Int->Int->Void> = new FlxTypedSignal<Int->Int->Void>();

	public var preGameReset(default, null):FlxSignal = new FlxSignal();
	public var postGameReset(default, null):FlxSignal = new FlxSignal();

	/**
	 * Gets dispatched just before the game is started (before the first state after the splash screen is created)
	 * @since 4.6.0
	 */
	public var preGameStart(default, null):FlxSignal = new FlxSignal();

	/**
	 * Gets dispatched when the game is started (first state after the splash screen).
	 * @since 4.6.0
	 */
	public var postGameStart(default, null):FlxSignal = new FlxSignal();

	@:deprecated("Use postGameStart instead of gameStarted")
	public var gameStarted(get, never):FlxSignal;
	public var preUpdate(default, null):FlxSignal = new FlxSignal();
	public var postUpdate(default, null):FlxSignal = new FlxSignal();
	public var preDraw(default, null):FlxSignal = new FlxSignal();
	public var postDraw(default, null):FlxSignal = new FlxSignal();
	public var focusGained(default, null):FlxSignal = new FlxSignal();
	public var focusLost(default, null):FlxSignal = new FlxSignal();

	@:allow(flixel.FlxG)
	function new() {}

	function get_stateSwitched():FlxSignal
	{
		return preStateSwitch;
	}

	function get_gameStarted():FlxSignal
	{
		return postGameStart;
	}
}
