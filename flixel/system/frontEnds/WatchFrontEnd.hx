package flixel.system.frontEnds;

import flixel.FlxG;

class WatchFrontEnd
{
	public function new() {}

	/**
	 * Add a variable to the watch list in the debugger.
	 * This lets you see the value of the variable all the time.
	 * 
	 * @param	object		A reference to any object in your game, e.g. Player or Robot or this.
	 * @param	field		The name of the variable you want to watch, in quotes, as a string: e.g. "speed" or "health".
	 * @param	displayName	Optional, display your own string instead of the class name + variable name: e.g. "enemy count".
	 */
	public inline function add(object:Dynamic, field:String, ?displayName:String):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.watch.add(displayName, FIELD(object, field));
		#end
	}
	
	/**
	 * Remove a variable from the watch list in the debugger.
	 * 
	 * @param	object	A reference to any object in your game, e.g. Player or Robot or this.
	 * @param	field	The name of the variable you want to watch, in quotes, as a string: e.g. "speed" or "health".
	 */
	public inline function remove(object:Dynamic, field:String):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.watch.remove(null, FIELD(object, field));
		#end
	}
	
	/**
	 * Add or update a quickWatch entry to the watch list in the debugger.
	 * Extremely useful when called in update() functions when there 
	 * doesn't exist a variable for a value you want to watch - so you won't have to create one.
	 * 
	 * @param	displayName	The name of the quickWatch entry, for example `"mousePressed"`.
	 * @param	value		The new value for this entry, for example `FlxG.mouse.pressed`.
	 */
	public inline function addQuick(displayName:String, value:Dynamic):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.watch.add(displayName, QUICK(value));
		#end
	}
	
	/**
	 * Remove a quickWatch entry from the watch list of the debugger.
	 * 
	 * @param	displayName	The name of the quickWatch entry you want to remove.
	 */
	public inline function removeQuick(displayName:String):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.watch.remove(displayName, QUICK(null));
		#end
	}
	
	/**
	 * Add an expression to the watch list in the debugger.
	 * The expression gets evaluated with hscript, and you can see its current value all the time.
	 * 
	 * @param	expression		A Haxe expression written as a string that will be evaluated and watched.
	 * @param	displayName		Optional, display your own string instead of the expression string: e.g. "enemy count".
	 */
	public function addExpression(expression:String, ?displayName:String):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.watch.add(displayName, EXPRESSION(expression));
		#end
	}
	
	/**
	 * Remove an expression from the watch list in the debugger.
	 * 
	 * @param	expression	The Haxe expression that you want to remove.
	 */
	public function removeExpression(expression:String):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.watch.remove(null, EXPRESSION(expression));
		#end
	}
	
	/**
	 * Add the mouse coords to the watch window. Useful for quickly 
	 * getting coordinates for object placement during prototyping!
	 */
	public inline function addMouse():Void
	{
		#if FLX_DEBUG
		add(FlxG, "mouse", "Mouse Position");
		#end
	}
	
	/**
	 * Removes the mouse coords from the watch window.
	 */
	public inline function removeMouse():Void
	{
		#if FLX_DEBUG
		remove(FlxG, "mouse");
		#end
	}
}