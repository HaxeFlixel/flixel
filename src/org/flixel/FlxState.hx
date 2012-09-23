package org.flixel;

/**
 * This is the basic game "state" object - e.g. in a simple game
 * you might have a menu state and a play state.
 * It is for all intents and purpose a fancy FlxGroup.
 * And really, it's not even that fancy.
 */
class FlxState extends FlxGroup
{
	private var _layers:Array<FlxLayer>;
	
	public function new()
	{
		super();
		_layers = [];
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		// TODO: destroy layers
		_layers = null;
	}
	
	/**
	 * This function is called after the game engine successfully switches states.
	 * Override this function, NOT the constructor, to initialize or set up your game state.
	 * We do NOT recommend overriding the constructor, unless you want some crazy unpredictable things to happen!
	 */
	public function create():Void { }
	
	// TODO: methods for layer manipulation
	
}