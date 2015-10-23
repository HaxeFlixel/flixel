package flixel.system.debug;

#if !FLX_NO_DEBUG
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.util.FlxStringUtil;

class ConsoleCommands
{
	private var _console:Console;
	/**
	 * Helper variable for toggling the mouse coords in the watch window.
	 */
	private var _watchingMouse:Bool = false;
	
	public function new(console:Console):Void
	{
		#if !FLX_NO_DEBUG
		_console = console;
		/*
		console.addCommand(["create", "cr"], create, "Creates a new FlxObject and registers it - by default at the mouse position.", 
							"[FlxObject] (MousePos = true)", 3, 3);
		
		console.addCommand(["watchMouse", "wm"], watchMouse, "Adds the mouse coordinates to the watch window.");
		console.addCommand(["track", "t"], track, "Adds a tracker window for the specified object or class.");
		*/
		
		console.registerFunction("help", help, "Displays the help text of a registered object or function. See \"help\".");
		console.registerFunction("close", close, "Closes the debugger overlay.");
		
		console.registerFunction("clearHistory", clearHistory, "Closes the debugger overlay.");
		console.registerFunction("clearLog", FlxG.log.clear, "Clears the command history.");
		
		console.registerFunction("resetState", resetState, "Resets the current state.");
		console.registerFunction("switchState", switchState, "Switches to the specified state. Ex: \"switchState(new TestState())\". Be sure the class of the new state is a registered object!");
		console.registerFunction("resetGame", resetGame, "Resets the game.");
		
		console.registerFunction("fields", fields, "Lists the fields of a class or instance");
		
		console.registerFunction("listObjects", listObjects, "Lists the aliases of all registered objects.");
		console.registerFunction("listFunctions", listFunctions, "Lists the aliases of all registered functions.");
		
		console.registerFunction("pause", pause, "Toggles the game between paused and unpaused.");
		
		console.registerFunction("clearBitmapLog", FlxG.bitmapLog.clear, "Clears the bitmapLog window.");
		console.registerFunction("viewCache", FlxG.bitmapLog.viewCache, "Adds the cache to the bitmapLog window.");
		
		// Default classes to include
		console.registerObject("Math", Math);
		console.registerObject("FlxG", FlxG);
		
		#end
	}
	
	private function help(?Alias:String):String
	{
		if (Alias == null || Alias.length == 0) 
		{
			var output:String = "System classes and commands: ";
			for (obj in _console.registeredObjects.keys())
			{
				output += obj + ", ";
			}
			for (func in _console.registeredFunctions.keys())
			{
				output += func + "(), ";
			}
			return output + "\nTry 'help(\"command\")' for more information about a specific command."; 
		}
		else 
		{
			if (_console.registeredHelp.exists(Alias))
			{
				return Alias + (_console.registeredFunctions.exists(Alias) ? "()" : "") + ": " + _console.registeredHelp.get(Alias);
			}
			
			else
			{
				FlxG.log.error("Help: The command '" + Alias + "' does not have help text.");
				return null;
			}
		}
	}
	
	#if !FLX_NO_DEBUG
	private inline function close():Void
	{
		FlxG.debugger.visible = false;
	}
	
	private inline function clearHistory():Void
	{
		_console.cmdHistory.splice(0, _console.cmdHistory.length);
		FlxG.save.flush();
		ConsoleUtil.log("clearHistory: Command history cleared");
	}
	
	private inline function resetState():Void
	{
		FlxG.resetState();
		ConsoleUtil.log("resetState: State has been reset");
	}
	
	private function switchState(State:FlxState):Void 
	{
		if (State == null)
			return;
		
		FlxG.switchState(State);
		ConsoleUtil.log("switchState: New '" + Type.getClass(State) + "' created");  
	}
	
	private inline function resetGame():Void
	{
		FlxG.resetGame();
		ConsoleUtil.log("resetGame: Game has been reset");
	}
	
	/*
	private function create(ClassName:String, MousePos:String = "true", ?Params:Array<String>):Void
	{
		if (Params == null)
			Params = [];

		var instance:Dynamic = ConsoleUtil.attemptToCreateInstance(ClassName, FlxObject, Params);
		if (instance == null)
			return;

		var obj:FlxObject = instance;

		if (MousePos == "true")
		{
			obj.x = FlxG.game.mouseX;
			obj.y = FlxG.game.mouseY;
		}

		FlxG.state.add(instance);

		if (Params.length == 0)
			ConsoleUtil.log("create: New " + ClassName + " created at X = " + obj.x + " Y = " + obj.y);
		else
			ConsoleUtil.log("create: New " + ClassName + " created at X = " + obj.x + " Y = " + obj.y + " with params " + Params);

		_console.objectStack.push(instance);
		_console.registerObject(Std.string(_console.objectStack.length), instance);

		ConsoleUtil.log("create: " + ClassName + " registered as object '" + _console.objectStack.length + "'");
	}
	*/
	
	private function fields(Object:Dynamic):String
	{
		var fields:Array<String> = null;
		// passed a class -> get static fields
		if (Std.is(Object, Class))
		{
			fields = Type.getClassFields(Object);
		}
		else if (Reflect.isObject(Object)) // get instance fields
		{
			fields = Type.getInstanceFields((Type.getClass(Object)));
		}
		
		else
		{
			return "Can't get the fields of a registered function.";
		}
		
		for (i in 0...fields.length)
		{
			fields[i] += ":" + Reflect.getProperty(Object, fields[i]);
		}
		
		ConsoleUtil.log("List of fields for " + Object + ":");
		var output:String = "";
		for (field in fields)
		{
			output += field + "\n";
		}
		
		return StringTools.rtrim(output);
	}
	
	private inline function listObjects():Void
	{
		ConsoleUtil.log("Objects registered: \n" + FlxStringUtil.formatStringMap(_console.registeredObjects)); 
	}
	
	private inline function listFunctions():Void
	{
		ConsoleUtil.log("Functions registered: \n" + FlxStringUtil.formatStringMap(_console.registeredFunctions)); 
	}
	
	private function watchMouse():Void
	{
		if (!_watchingMouse) 
		{
			FlxG.watch.addMouse();
			ConsoleUtil.log("watchMouse: Mouse position added to watch window");
		}
		else 
		{
			FlxG.watch.removeMouse();
			ConsoleUtil.log("watchMouse: Mouse position removed from watch window");
		}
		
		_watchingMouse = !_watchingMouse;
	}
	
	/*
	private function track(ObjectAndVariable:String):Void
	{
		if (ObjectAndVariable != null)
		{
			var path:PathToVariable = ConsoleUtil.resolveObjectAndVariableFromMap(ObjectAndVariable, _console.registeredObjects);
			var objectOrClass = 
				if (path.variableName == "") // Class<T>
					path.object;
				else
					Reflect.getProperty(path.object, path.variableName);
				
			FlxG.debugger.track(objectOrClass);
		}
	}
	*/
	
	private function pause():Void
	{
		if (FlxG.vcr.paused) 
		{
			FlxG.vcr.resume();
			ConsoleUtil.log("pause: Game unpaused");
		}
		else 
		{
			FlxG.vcr.pause();
			ConsoleUtil.log("pause: Game paused");
		}
	}
	#end
}
#end
