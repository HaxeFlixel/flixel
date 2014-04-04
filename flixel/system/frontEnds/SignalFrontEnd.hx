package flixel.system.frontEnds;

import flixel.util.FlxSignal;

class SignalFrontEnd
{
	/**
	 * Gets dispatched when a state change occurs. Signal.userData is null!
	 */
	public var stateSwitch(default, null):FlxSignal;
	/**
	 * Gets dispatched when the game is resized. Signal.userData is a FlxPoint (FlxG.scaleMode.gameSize)!
	 */
	public var gameResize(default, null):FlxSignal;
	public var gameReset(default, null):FlxSignal;
	/**
	 * Gets dispatched when the game is started (first state after the splash screen).
	 */
	public var gameStart(default, null):FlxSignal;
	public var preUpdate(default, null):FlxSignal;
	public var postUpdate(default, null):FlxSignal;
	public var preDraw(default, null):FlxSignal;
	public var postDraw(default, null):FlxSignal;
	public var focusGained(default, null):FlxSignal;
	public var focusLost(default, null):FlxSignal;
	
	@:allow(flixel.FlxG)
	private function new() 
	{
		stateSwitch = FlxSignal.get().add(FlxSignal.onStateSwitch);
		gameResize = FlxSignal.get();
		gameReset = FlxSignal.get();
		gameStart = FlxSignal.get();
		preUpdate = FlxSignal.get();
		postUpdate = FlxSignal.get();
		preDraw = FlxSignal.get();
		postDraw = FlxSignal.get();
		focusGained = FlxSignal.get();
		focusLost = FlxSignal.get();
	}
}