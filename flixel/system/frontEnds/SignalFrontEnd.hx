package flixel.system.frontEnds;

import flixel.util.FlxSignal;

class SignalFrontEnd
{
	/**
	 * Gets dispatched when a state change occurs.
	 */
	public var stateSwitched(default, null):FlxSignal = new FlxSignal();
	public var preStateCreate(default, null):FlxTypedSignal<FlxState->Void> = new FlxTypedSignal<FlxState->Void>();
	/**
	 * Gets dispatched when the game is resized. 
	 * Passes the new window width and height to callback functions.
	 */
	public var gameResized(default, null):FlxTypedSignal<Int->Int->Void> = new FlxTypedSignal<Int->Int->Void>();
	public var preGameReset(default, null):FlxSignal = new FlxSignal();
	public var postGameReset(default, null):FlxSignal = new FlxSignal();
	/**
	 * Gets dispatched when the game is started (first state after the splash screen).
	 */
	public var gameStarted(default, null):FlxSignal = new FlxSignal();
	public var preUpdate(default, null):FlxSignal = new FlxSignal();
	public var postUpdate(default, null):FlxSignal = new FlxSignal();
	public var preDraw(default, null):FlxSignal = new FlxSignal();
	public var postDraw(default, null):FlxSignal = new FlxSignal();
	public var focusGained(default, null):FlxSignal = new FlxSignal();
	public var focusLost(default, null):FlxSignal = new FlxSignal();
	#if FLX_DEBUG
	/**
	 * Gets dispatched when the debugger is showed (usually by
	 * pressing the key below ESC)
	 */
	public var debuggerShowed(default, null):FlxSignal = new FlxSignal();
	/**
	 * Gets dispatched when the debugger is hid (usually by
	 * pressing the key below ESC)
	 */
	public var debuggerHid(default, null):FlxSignal = new FlxSignal();
	#end
	
	@:allow(flixel.FlxG)
	private function new() {}
}
