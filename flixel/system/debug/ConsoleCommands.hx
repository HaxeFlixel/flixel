package flixel.system.debug;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.system.debug.Console.Command;
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
			cLog(output);
			cLog("help (Command) for more information about a specific command"); 
		}
		else 
		{
			var command:Command = _console.findCommand(Alias);
			
			if (command != null)
			{
				FlxG.log.add("");
				cLog(command.aliases);
				
				if (command.help != null) {
					cLog(command.help);
				}
				
				var cutoffHelp:String = "";
				if (command.paramCutoff > 0) {
					cutoffHelp = " [param0...paramX]";
				}
				
				if (command.paramHelp != null || cutoffHelp != "") {
					cLog("Params: " + command.paramHelp + cutoffHelp);
				}
			}
			else 
			{
				FlxG.log.error("A command named '" + Alias + "' does not exist");
			}
		}
	}
	
	inline private function clearHistory():Void
	{
		_console.cmdHistory = new Array<String>();
		FlxG.save.flush();
		cLog("clearHistory: Command history cleared");
	}
	
	inline private function resetState():Void
	{
		FlxG.resetState();
		cLog("resetState: State has been reset");
	}
	
	private function switchState(ClassName:String):Void 
	{
		var instance:Dynamic = attemptToCreateInstance(ClassName, FlxState, "switchState");
		if (instance == null) {
			return;
		}
		
		FlxG.switchState(instance);
		cLog("switchState: New '" + ClassName + "' created");  
	}
	
	inline private function resetGame():Void
	{
		FlxG.resetGame();
		cLog("resetGame: Game has been reset");
	}
	
	private function watchMouse():Void
	{
		if (!_watchingMouse) 
		{
			FlxG.watch.addMouse();
			cLog("watchMouse: Mouse position added to watch window");
		}
		else 
		{
			FlxG.watch.removeMouse();
			cLog("watchMouse: Mouse position removed from watch window");
		}
		
		_watchingMouse = !_watchingMouse;
	}
	
	private function pause():Void
	{
		if (FlxG.vcr.paused) {
			FlxG.vcr.resume();
			cLog("pause: Game unpaused");
		}
		else {
			FlxG.vcr.pause();
			cLog("pause: Game paused");
		}
	}
	
	inline private function close():Void
	{
		FlxG.debugger.visible = false;
	}
	
	private function create(ClassName:String, MousePos:String = "true", ?Params:Array<String>):Void
	{	
		if (Params == null) {
			Params = [];
		}
		
		var instance:Dynamic = attemptToCreateInstance(ClassName, FlxObject, "create", Params);
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
			cLog("create: New " + ClassName + " created at X = " + obj.x + " Y = " + obj.y);
		}
		else {
			cLog("create: New " + ClassName + " created at X = " + obj.x + " Y = " + obj.y + " with params " + Params);
		}
			
		_console.objectStack.push(instance);
		_console.registerObject(Std.string(_console.objectStack.length), instance);
		
		cLog("create: " + ClassName + " registered as object '" + _console.objectStack.length + "'");
	}
	
	private function set(ObjectAndVariable:String, NewVariableValue:Dynamic, ?WatchName:String):Void
	{
		var info:Array<Dynamic> = resolveObjectAndVariable(ObjectAndVariable, "set");
		
		// In case resolving failed
		if (info == null) {
			return;
		}
			
		var object:Dynamic = info[0];
		var varName:String = info[1];
		var variable:Dynamic = null;
		
		try
		{
			variable = Reflect.getProperty(object, varName);
		}
		catch (e:Dynamic)
		{
			return;
		}
		
		// Workaround to make Booleans work
		if (Std.is(variable, Bool)) 
		{
			if (NewVariableValue == "false" || NewVariableValue == "0") { 
				NewVariableValue = false;
			}
			else if (NewVariableValue == "true" || NewVariableValue == "1") {
				NewVariableValue = true;
			}
			else {
				FlxG.log.error("set: '" + NewVariableValue + "' is not a valid value for Booelan '" + varName + "'");
				return;
			}
		}
		
		// Prevent turning numbers into NaN
		else if (Std.is(variable, Float) && Math.isNaN(Std.parseFloat(NewVariableValue))) 
		{
			FlxG.log.error("set: '" + NewVariableValue + "' is not a valid value for number '" + varName + "'");
			return;
		}
		// Prevent setting non "simple" typed properties
		else if (!Std.is(variable, Float) && !Std.is(variable, Bool) && !Std.is(variable, String))
		{
			FlxG.log.error("set: '" + varName + ":" + Std.string(variable) + "' is not of a simple type (number, bool or string)");
			return;
		}
		
		Reflect.setProperty(object, varName, NewVariableValue);
		cLog("set: " + Std.string(object) + "." + varName + " is now " + NewVariableValue);
		
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
				FlxG.log.error("call: '" + Std.string(object) + "' is not a valid Object to call function from");
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
					FlxG.log.error("call: " + Std.string(tempObj) + " does not have a field '" + tempVarName + "' to call function from");
					return;
				}
				
				tempObj = Reflect.getProperty(tempObj, tempVarName);
			}
			
			func = Reflect.field(tempObj, searchArr[l]);
			
			if (func == null)
			{
				FlxG.log.error("call: " + Std.string(tempObj) + " does not have a method '" + searchArr[l] + "' to call");
				return;
			}
		}
		
		if (Reflect.isFunction(func)) {
			var success:Bool = _console.callFunction(func, Params);
			
			if (Params.length == 0 && success) {
				cLog("call: Called '" + FunctionAlias + "'");
			}
			else if (success) {
				cLog("call: Called '" + FunctionAlias + "' with params " + Params);
			}
		}
		else {
			FlxG.log.error("call: '" + FunctionAlias + "' is not a valid function");
		}
	}
	
	inline private function listObjects():Void
	{
		cLog("Objects registered: \n" + FlxStringUtil.formatStringMap(_console.registeredObjects)); 
	}
	
	inline private function listFunctions():Void
	{
		cLog("Functions registered: \n" + FlxStringUtil.formatStringMap(_console.registeredFunctions)); 
	}
	
	/**
	 * Helper functions
	 */
	
	private function attemptToCreateInstance(ClassName:String, _Type:Dynamic, CommandName:String, ?Params:Array<String>):Dynamic
	{
		if (Params == null) {
			Params = [];
		}
		
		var obj:Dynamic = Type.resolveClass(ClassName);
		if (!Reflect.isObject(obj)) {
			FlxG.log.error(CommandName + ": '" + ClassName + "' is not a valid class name. Try passing the full class path. Also make sure the class is being compiled.");
			return null;
		}
		
		var instance:Dynamic = Type.createInstance(obj, Params);
		
		if (!Std.is(instance, _Type)) {
			FlxG.log.error(CommandName + ": '" + ClassName + "' is not a " + Type.getClassName(_Type));
			return null;
		}
		
		return instance;
	}
	
	private function resolveObjectAndVariable(ObjectAndVariable:String, CommandName:String):Array<Dynamic>
	{
		var searchArr:Array<String> = ObjectAndVariable.split(".");
		
		// In case there's not dot in the string
		if (searchArr[0].length == ObjectAndVariable.length) {
			FlxG.log.error(CommandName + ": '" + ObjectAndVariable + "' does not refer to an object's field");
			return null;
		}
		
		var object:Dynamic = _console.registeredObjects.get(searchArr.shift());
		var variableName:String = searchArr.join(".");
		
		if (!Reflect.isObject(object)) {
			FlxG.log.error(CommandName + ": '" + Std.string(object) + "' is not a valid Object");
			return null;
		}
		
		// Searching for property...
		var l:Int = searchArr.length;
		var tempObj:Dynamic = object;
		var tempVarName:String = "";
		for (i in 0...l)
		{
			tempVarName = searchArr[i];
			
			try 
			{
				if (i < (l - 1))
				{
					tempObj = Reflect.getProperty(tempObj, tempVarName);
				}
			}
			catch (e:Dynamic) 
			{
				FlxG.log.error(CommandName + ": " + Std.string(tempObj) + " does not have a field '" + tempVarName + "'");
				return null;
			}
		}
		
		return [tempObj, tempVarName];
	}
	
	inline private function cLog(Text:Dynamic):Void
	{
		FlxG.log.advanced([Text], LogStyle.CONSOLE);
	}
	#end
}