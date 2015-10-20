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
		// Install commands
		console.addCommand(["help", "h"], help, null, "(Command)", 1);
		console.addCommand(["close", "cl"], close, "Closes the debugger overlay.");
		console.addCommand(["clearHistory", "ch"], clearHistory, "Clears the command history.");
		
		console.addCommand(["clearLog", "clear"], FlxG.log.clear, "Clears the log window.");
		
		console.addCommand(["resetState", "rs"], resetState, "Resets the current state.");
		console.addCommand(["switchState", "ss"], switchState, "Switches to a specified state.", "[FlxState]");
		console.addCommand(["resetGame", "rg"], resetGame, "Resets the game.");
		
		console.addCommand(["create", "cr"], create, "Creates a new FlxObject and registers it - by default at the mouse position.", 
							"[FlxObject] (MousePos = true)", 3, 3);
		console.addCommand(["set", "s"], set, "Sets a variable within a registered object.", "[Path to variable] [Value] (WatchName)", 3);
		console.addCommand(["get", "g"], get, "Gets a variable within a registered object or the object itself.", "[Path to variable] (WatchName)", 2);
		console.addCommand(["call", "c"], call, "Calls a registered function / function within a registered object.", 3, 2);
		console.addCommand(["fields", "f"], fields, "Lists the fields of a class or instance", "[Class or path to instance] (NumSuperClassesToInclude = 0)", 2);
		
		console.addCommand(["listObjects", "lo"], listObjects, "Lists all the aliases of the registered objects.");
		console.addCommand(["listFunctions", "lf"], listFunctions, "Lists all the aliases of the registered objects.");
		
		console.addCommand(["watchMouse", "wm"], watchMouse, "Adds the mouse coordinates to the watch window.");
		console.addCommand(["track", "t"], track, "Adds a tracker window for the specified object or class.");
		
		console.addCommand(["pause", "p"], pause, "Toggle between paused and unpaused");
		
		console.addCommand(["clearBitmapLog", "cbl"], FlxG.bitmapLog.clear, "Clears the bitmapLog window.");
		console.addCommand(["viewCache", "vc"], FlxG.bitmapLog.viewCache, "Adds the cache to the bitmapLog window");
		
		// Default registration
		console.registerObject("FlxG", FlxG);
		*/
		
		console.registerObject("Math", Math);
		console.registerObject("FlxG", FlxG);
		
		#end
	}
	
	/*
	private function help(?Alias:String):Void
	{
		if (Alias == null) 
		{
			var output:String = "System commands: ";
			for (command in _console.commands)
			{
				output += command.aliases[0] + ", ";
			}
			ConsoleUtil.log(output);
			ConsoleUtil.log("help (Command) for more information about a specific command"); 
		}
		else 
		{
			var command:Command = ConsoleUtil.findCommand(Alias, _console.commands);
			
			if (command != null)
			{
				FlxG.log.add("");
				ConsoleUtil.log(command.aliases);
				
				if (command.help != null)
					ConsoleUtil.log(command.help);
				
				var cutoffHelp:String = "";
				if (command.paramCutoff > 0)
					cutoffHelp = " [param0...paramX]";
				
				if (command.paramHelp != null || cutoffHelp != "")
					ConsoleUtil.log("Params: " + command.paramHelp + cutoffHelp);
			}
			else 
			{
				FlxG.log.error("A command named '" + Alias + "' does not exist");
			}
		}
	}
	*/
	
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
	
	/*
	private function switchState(ClassName:String):Void 
	{
		var instance:Dynamic = ConsoleUtil.attemptToCreateInstance(ClassName, FlxState);
		if (instance == null)
			return;
		
		FlxG.switchState(instance);
		ConsoleUtil.log("switchState: New '" + ClassName + "' created");  
	}
	*/
	
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
	
	/*
	private function fields(ObjectAndVariable:String, NumSuperClassesToInclude:Int = 0):Void
	{
		var pathToVariable:PathToVariable = ConsoleUtil.resolveObjectAndVariableFromMap(ObjectAndVariable, _console.registeredObjects);
		
		// In case resolving failed
		if (pathToVariable == null)
			return;
	
		var fields:Array<String> = [];
		var isClass:Bool = Std.is(pathToVariable.object, Class);
		
		// passed a class -> get static fields
		if (isClass && pathToVariable.variableName == "")
		{
			fields = Type.getClassFields(pathToVariable.object);
		}
		else // get instance fields
		{
			var instance = Reflect.getProperty(pathToVariable.object, pathToVariable.variableName);
			if (instance == null)
				return;
		
			var cl = Type.getClass(instance);
			fields = ConsoleUtil.getInstanceFieldsAdvanced(cl, NumSuperClassesToInclude);
		}
		
		var object = isClass ? pathToVariable.object : 
			Reflect.getProperty(pathToVariable.object, pathToVariable.variableName);
		
		for (i in 0...fields.length)
		{
			fields[i] += ":" + ConsoleUtil.getTypeName(Reflect.getProperty(object, fields[i]));
		}
		
		ConsoleUtil.log("fields: list of fields for " + ObjectAndVariable);
		var output:String = "";
		for (field in fields)
		{
			output += field + "\n";
		}
		ConsoleUtil.log(output);
	}
	*/
	
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
