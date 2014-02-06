package flixel.system.debug;

#if !FLX_NO_DEBUG
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.system.debug.Console.Command;
import flixel.system.debug.ConsoleUtil.PathToVariable;
import flixel.util.FlxStringUtil;

class ConsoleCommands
{
	/**
	 * Reference to the console window.
	 */
	private var _console:Console;
	/**
	 * Helper variable for toggling the mouse coords in the watch window.
	 */
	private var _watchingMouse:Bool = false;
	
	public function new(console:Console):Void
	{
		#if !FLX_NO_DEBUG
		_console = console;
		
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
		console.addCommand(["set", "s"], set, "Sets a variable within a registered object.", "[Path to function]", 3);
		console.addCommand(["call", "c"], call, "Calls a registered function / function within a registered object.", 3, 2);
		
		console.addCommand(["listObjects", "lo"], listObjects, "Lists all the aliases of the registered objects.");
		console.addCommand(["listFunctions", "lf"], listFunctions, "Lists all the aliases of the registered objects.");
		
		console.addCommand(["watchMouse", "wm"], watchMouse, "Adds the mouse coordinates to the watch window.");
		
		console.addCommand(["pause", "p"], pause, "Toggle between paused and unpaused");
		
		// Default registration
		console.registerObject("FlxG", FlxG);
		#end
	}
	
	/**
	 * Commands
	 */
	
	#if !FLX_NO_DEBUG
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
				
				if (command.help != null) {
					ConsoleUtil.log(command.help);
				}
				
				var cutoffHelp:String = "";
				if (command.paramCutoff > 0) {
					cutoffHelp = " [param0...paramX]";
				}
				
				if (command.paramHelp != null || cutoffHelp != "") {
					ConsoleUtil.log("Params: " + command.paramHelp + cutoffHelp);
				}
			}
			else 
			{
				FlxG.log.error("A command named '" + Alias + "' does not exist");
			}
		}
	}
	
	private inline function close():Void
	{
		FlxG.debugger.visible = false;
	}
	
	private inline function clearHistory():Void
	{
		_console.cmdHistory = new Array<String>();
		FlxG.save.flush();
		ConsoleUtil.log("clearHistory: Command history cleared");
	}
	
	private inline function resetState():Void
	{
		FlxG.resetState();
		ConsoleUtil.log("resetState: State has been reset");
	}
	
	private function switchState(ClassName:String):Void 
	{
		var instance:Dynamic = ConsoleUtil.attemptToCreateInstance(ClassName, FlxState);
		if (instance == null) {
			return;
		}
		
		FlxG.switchState(instance);
		ConsoleUtil.log("switchState: New '" + ClassName + "' created");  
	}
	
	private inline function resetGame():Void
	{
		FlxG.resetGame();
		ConsoleUtil.log("resetGame: Game has been reset");
	}
	
	private function create(ClassName:String, MousePos:String = "true", ?Params:Array<String>):Void
	{	
		if (Params == null) {
			Params = [];
		}
		
		var instance:Dynamic = ConsoleUtil.attemptToCreateInstance(ClassName, FlxObject, Params);
		if (instance == null) {
			return;
		}
		
		var obj:FlxObject = instance;
		
		if (MousePos == "true") {
			obj.x = FlxG.game.mouseX;
			obj.y = FlxG.game.mouseY;
		}
		
		FlxG.state.add(instance);
		
		if (Params.length == 0) {
			ConsoleUtil.log("create: New " + ClassName + " created at X = " + obj.x + " Y = " + obj.y);
		}
		else {
			ConsoleUtil.log("create: New " + ClassName + " created at X = " + obj.x + " Y = " + obj.y + " with params " + Params);
		}
		
		_console.objectStack.push(instance);
		_console.registerObject(Std.string(_console.objectStack.length), instance);
		
		ConsoleUtil.log("create: " + ClassName + " registered as object '" + _console.objectStack.length + "'");
	}
	
	private function set(ObjectAndVariable:String, NewVariableValue:Dynamic, ?WatchName:String):Void
	{
		var pathToVariable:PathToVariable = ConsoleUtil.resolveObjectAndVariable(ObjectAndVariable, _console.registeredObjects);
		
		// In case resolving failed
		if (pathToVariable == null) {
			return;
		}
		
		var object:Dynamic = pathToVariable.object;
		var varName:String = pathToVariable.variableName;
		var variable:Dynamic = null;
		
		try
		{
			variable = Reflect.getProperty(object, varName);
		}
		catch (e:Dynamic)
		{
			return;
		}
		
		// Prevent from assigning non-boolean values to bools
		if (Std.is(variable, Bool)) 
		{
			var oldVal = NewVariableValue;
			NewVariableValue = ConsoleUtil.parseBool(NewVariableValue);
			
			if (NewVariableValue == null)
			{
				FlxG.log.error("set: '" + oldVal + "' is not a valid value for Bool '" + varName + "'");
				return;
			}
		}
		
		// Prevent turning numbers into NaN
		if (Std.is(variable, Float) && Math.isNaN(Std.parseFloat(NewVariableValue))) 
		{
			FlxG.log.error("set: '" + NewVariableValue + "' is not a valid value for number '" + varName + "'");
			return;
		}
		// Prevent setting non "simple" typed properties
		else if (!Std.is(variable, Float) && !Std.is(variable, Bool) && !Std.is(variable, String))
		{
			FlxG.log.error("set: '" + varName + ":" + FlxStringUtil.getClassName(variable, true) + "' is not of a simple type (number, bool or string)");
			return;
		}
		
		Reflect.setProperty(object, varName, NewVariableValue);
		ConsoleUtil.log("set: " + FlxStringUtil.getClassName(object, true) + "." + varName + " is now " + NewVariableValue);
		
		if (WatchName != null) {
			FlxG.watch.add(object, varName, WatchName);
		}
	}
	
	private function call(FunctionAlias:String, ?Params:Array<String>):Void
	{	
		if (Params == null) {
			Params = [];
		}
		
		// Search for function in registeredFunctions hash
		var func:Dynamic = _console.registeredFunctions.get(FunctionAlias);
		
		// Otherwise, we'll search for function in registeredObjects' methods
		if (!Reflect.isFunction(func))
		{
			var searchArr:Array<String> = FunctionAlias.split(".");
			var objectName:String = searchArr.shift();
			var object:Dynamic = _console.registeredObjects.get(objectName);
			
			if (!Reflect.isObject(object)) 
			{
				FlxG.log.error("call: '" + FlxStringUtil.getClassName(object, true) + "' is not a valid Object to call");
				return;
			}
			
			var tempObj:Dynamic = object;
			var tempVarName:String = "";
			var funcName:String = "";
			var l:Int = searchArr.length - 1;
			for (i in 0...l)
			{
				tempVarName = searchArr[i];
				
				try 
				{
					var prop:Dynamic = Reflect.getProperty(tempObj, tempVarName);
				}
				catch (e:Dynamic) 
				{
					FlxG.log.error("call: " + FlxStringUtil.getClassName(tempObj, true) + " does not have a field '" + tempVarName + "' to call");
					return;
				}
				
				tempObj = Reflect.getProperty(tempObj, tempVarName);
			}
			
			func = Reflect.field(tempObj, searchArr[l]);
			
			if (func == null)
			{
				FlxG.log.error("call: " + FlxStringUtil.getClassName(tempObj, true) + " does not have a method '" + searchArr[l] + "' to call");
				return;
			}
		}
		
		if (Reflect.isFunction(func)) 
		{
			var success:Bool = ConsoleUtil.callFunction(func, Params);
			
			if (Params.length == 0 && success) {
				ConsoleUtil.log("call: Called '" + FunctionAlias + "()'");
			}
			else if (success) {
				ConsoleUtil.log("call: Called '" + FunctionAlias + "()' with params " + Params);
			}
		}
		else {
			FlxG.log.error("call: '" + FunctionAlias + "' is not a valid function");
		}
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