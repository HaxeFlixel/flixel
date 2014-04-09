package flixel.system.frontEnds;

import flixel.util.FlxPoint;
import flixel.util.FlxSignal;

class SignalFrontEnd
{
	/**
	 * Gets dispatched when a state change occurs.
	 */
	public var stateSwitched(default, null):FlxSignal;
	/**
	 * Gets dispatched when the game is resized. 
	 * Passes the new window width and height to callback functions.
	 */
	public var gameResized(default, null):FlxTypedSignal<Int->Int->Void>;
	public var gameReset(default, null):FlxSignal;
	/**
	 * Gets dispatched when the game is started (first state after the splash screen).
	 */
	public var gameStarted(default, null):FlxSignal;
	public var preUpdate(default, null):FlxSignal;
	public var postUpdate(default, null):FlxSignal;
	public var preDraw(default, null):FlxSignal;
	public var postDraw(default, null):FlxSignal;
	public var focusGained(default, null):FlxSignal;
	public var focusLost(default, null):FlxSignal;
	
	@:allow(flixel.FlxG)
	private function new() 
	{
		stateSwitched = new FlxSignal();
		gameResized = new FlxTypedSignal<Int->Int->Void>();
		gameReset = new FlxSignal();
		gameStarted = new FlxSignal();
		preUpdate = new FlxSignal();
		postUpdate = new FlxSignal();
		preDraw = new FlxSignal();
		postDraw = new FlxSignal();
		focusGained = new FlxSignal();
		focusLost = new FlxSignal();
	}
}