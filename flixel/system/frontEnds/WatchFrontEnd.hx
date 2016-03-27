package flixel.system.frontEnds;

import flixel.FlxG;

class WatchFrontEnd
{
	public function new() {}

	/**
	 * Add a variable to the watch list in the debugger.
	 * This lets you see the value of the variable all the time.
	 * 
	 * @param	AnyObject		A reference to any object in your game, e.g. Player or Robot or this.
	 * @param	VariableName	The name of the variable you want to watch, in quotes, as a string: e.g. "speed" or "health".
	 * @param	DisplayName		Optional, display your own string instead of the class name + variable name: e.g. "enemy count".
	 */
	public inline function add(AnyObject:Dynamic, VariableName:String, ?DisplayName:String):Void
	{
		#if FLX_DEBUG
		if (AnyObject != null)
			FlxG.game.debugger.watch.add(AnyObject, VariableName, DisplayName);
		#end
	}
	
	/**
	 * Remove a variable from the watch list in the debugger.
	 * Don't pass a Variable Name to remove all watched variables for the specified object.
	 * 
	 * @param	AnyObject		A reference to any object in your game, e.g. Player or Robot or this.
	 * @param	VariableName	The name of the variable you want to watch, in quotes, as a string: e.g. "speed" or "health".
	 */
	public inline function remove(AnyObject:Dynamic, ?VariableName:String):Void
	{
		#if FLX_DEBUG
		if (AnyObject != null)
			FlxG.game.debugger.watch.remove(AnyObject, VariableName);
		#end
	}
	
	/**
	 * Add or update a quickWatch entry to the watch list in the debugger.
	 * Extremely useful when called in update() functions when there 
	 * doesn't exist a variable for a value you want to watch - so you won't have to create one.
	 * 
	 * @param	Name		The name of the quickWatch entry, for example "mousePressed".
	 * @param	NewValue	The new value for this entry, for example FlxG.mouse.pressed.
	 */
	public inline function addQuick(Name:String, NewValue:Dynamic):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.watch.updateQuickWatch(Name, NewValue);
		#end
	}
	
	/**
	 * Remove a quickWatch entry from the watch list of the debugger.
	 * 
	 * @param	Name	The name of the quickWatch entry you want to remove.
	 */
	public inline function removeQuick(Name:String):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.watch.remove(null, null, Name);
		#end
	}
	
	/**
	 * Add an expression to the watch list in the debugger.
	 * The expression gets evaluated with hscript, and you can see its current value all the time.
	 * 
	 * @param	Expression		A Haxe expression written as a string that will be evaluated and watched.
	 * @param	DisplayName		Optional, display your own string instead of the expression string: e.g. "enemy count".
	 */
	public function addExpr(Expression:String, ?DisplayName:String):Void
	{
		#if (FLX_DEBUG && hscript)
		if (Expression != null && Expression.length > 0)
			FlxG.game.debugger.watch.add(null, Expression, DisplayName);
		#end
	}
	
	/**
	 * Remove an expression from the watch list in the debugger.
	 * You can pass the display name or the entire expression itself to remove it.
	 * 
	 * @param	Expression		The Haxe expression that you want to remove. Pass null if you wish to remove it by its display name instead.
	 * @param	DisplayName		The name of the expression you want to remove. Pass null (or don't pass anything) if the previous parameter is not null.
	 */
	public function removeExpr(?Expression:String, ?DisplayName:String):Void
	{
		#if (FLX_DEBUG && hscript)
		FlxG.game.debugger.watch.removeExpr(Expression, DisplayName);
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