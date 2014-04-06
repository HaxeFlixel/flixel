package flixel.system.frontEnds;

import flixel.util.FlxPoint;
import flixel.signals.FlxSignal;

class SignalFrontEnd
{
	/**
	 * Gets dispatched when a state change occurs.
	 */
	public var stateSwitch(default, null):FlxSignal0;
	/**
	 * Gets dispatched when the game is resized. 
	 * Passes the new window width and height to callback functions.
	 */
	public var gameResize(default, null):FlxSignal2<Int, Int>;
	public var gameReset(default, null):FlxSignal0;
	/**
	 * Gets dispatched when the game is started (first state after the splash screen).
	 */
	public var gameStart(default, null):FlxSignal0;
	public var preUpdate(default, null):FlxSignal0;
	public var postUpdate(default, null):FlxSignal0;
	public var preDraw(default, null):FlxSignal0;
	public var postDraw(default, null):FlxSignal0;
	public var focusGained(default, null):FlxSignal0;
	public var focusLost(default, null):FlxSignal0;	
	
	@:allow(flixel.FlxG)
	private function new() 
	{
		stateSwitch = new FlxSignal0();		
		gameResize = new FlxSignal2<Int, Int>();
		gameReset = new FlxSignal0();
		gameStart = new FlxSignal0();
		preUpdate = new FlxSignal0();
		postUpdate = new FlxSignal0();
		preDraw = new FlxSignal0();
		postDraw = new FlxSignal0();
		focusGained = new FlxSignal0();
		focusLost = new FlxSignal0();
	}
}