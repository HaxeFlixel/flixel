package org.flixel.system.debug;

import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxState;

class ConsoleCommands
{
	private var _console:Console;
	private var watchingMouse:Bool = false;
	
	public function new(console:Console):Void
	{
		_console = console;
		
		// Install commands
		console.addCommand("help", this, help, "h");
		console.addCommand("log", FlxG, FlxG.log);
		console.addCommand("clearLog", FlxG, FlxG.clearLog, "clear");
		console.addCommand("clearHistory", this, clearHistory, "ch");
		console.addCommand("resetState", this, resetState, "rs");
		console.addCommand("switchState", this, switchState, "ss");
		console.addCommand("resetGame", this, resetGame, "rg");
		#if flash
		console.addCommand("fullscreen", FlxG, FlxG.fullscreen, "fs");
		#end
		console.addCommand("watchMouse", this, watchMouse, "wm");
		console.addCommand("visualDebug", this, visualDebug, "vd");
		console.addCommand("pause", this, pause);
		console.addCommand("play", FlxG, FlxG.play, "p");
		console.addCommand("playMusic", FlxG, FlxG.playMusic, "pm");
		console.addCommand("bgColor", this, bgColor, "bg");
		console.addCommand("shake", this, shake, "sh");
		console.addCommand("close", this, close, "cl");
		console.addCommand("create", this, create, "cr");
		console.addCommand("set", this, set);
		console.addCommand("call", this, call);
		console.addCommand("listObjects", this, listObjects, "lo");
		console.addCommand("listFunctions", this, listFunctions, "lf");
		console.addCommand("watch", this, watch, "w");
		console.addCommand("unwatch", this, unwatch, "uw");
		
		// Registration
		console.registerObject("FlxG", FlxG);
	}
	
	private function help(Command:String = ""):Void
	{
		if (Command == "") {
			// Don't include the fullscreen command for non-flash targets
			var fs:String = "";
			#if flash
			fs = "fullscreen,";
			#end
			
			FlxG.log(">> System commands << \nlog, clearLog, clearHistory, help, resetState, switchState, resetGame, " + fs + " watchMouse, visualDebug, pause, play, playMusic, bgColor, shake, create, set, call, close, listObjects, listFunctions");
		}
		else {
			switch (Command) {
				case "log":
					FlxG.log("> log: Calls FlxG.log() with the text you enter");
					FlxG.log("> log [Text]");
				case "clearLog":
					FlxG.log("> clearLog: Clears the log window");
				case "clearHistory":
					FlxG.log("> clearHistory: Clears the command history");
				case "help":
					FlxG.log("> help: Lists all system commands or provides more info on a specified command");
					FlxG.log("> help (Command)");
				case "resetState":
					FlxG.log("> resetState: Calls FlxG.resetState()");
				case "resetGame":
					FlxG.log("> resetGame: Calls FlxG.resetGame()");
				case "switchState":
					FlxG.log("> switchState: Calls FlxG.switchState() with specified FlxState");
					FlxG.log("> switchState [FlxState]");
				#if flash
				case "fullscreen":
					FlxG.log("> fullscreen: Enables fullscreen mode");
				#end
				case "watchMouse":
					FlxG.log("> watchMouse: Adds the x and y pos of the mosue to the watch window. Super useful for GUI-Building stuff.");
				case "visualDebug":
					FlxG.log("> visualDebug: Toggles visual debugging");
				case "pause":
					FlxG.log("> pause: Pauses / unpauses the game");
				case "play":
					FlxG.log("> play: Plays a sound");
					FlxG.log("> play [Sound] (Volume = 1)");
				case "playMusic":
					FlxG.log("> playMusic: Sets up and plays a looping background soundtrack.");
					FlxG.log("> playMusic [Music] (Volume = 1)");
				case "bgColor":
					FlxG.log("> bgColor: Changes the background color to a specified color. You can also pass the colors 'red, green, blue, pink, white,  and black'");
					FlxG.log("> bgColor [Color]");
				case "shake":
					FlxG.log("> shake: Calls FlxG.shake()");
					FlxG.log("> shake (Intensity = 0.05) (Duration = 0.5)");
				case "close":
					FlxG.log("> close: Close the debugger overlay");
				case "create": 
					FlxG.log("> create: Creates a new FlxObject and registers it. Doesn't work if its constructor requires params");
					FlxG.log("> create [FlxObject] (x = mouse.x) (y = mouse.y)");
				case "set":
					FlxG.log("> set: Changes a var within a previosuly registered object via FlxG.console.registerObject. Supports nesting (a field within an object within a registered object). Set a WatchName if you want to add the var to the watch window.");
					FlxG.log("> set [Object.VariableName] [NewValue] (WatchName)");
				case "call":
					FlxG.log("> call: Calls a function previously registered via FlxG.console.registerFunction with a set of params (or a function of a registered object");
					FlxG.log("> call [(Object.)Function] [param0...paramX]");
				case "listObjects":
					FlxG.log("> listObjects: Lists all the aliases of the objects registered");
				case "listFunctions":
					FlxG.log("> listFunctions: Lists all the aliases of the functions registered");
				case "watch":
					FlxG.log("> watch: Calls FlxG.watch()");
					FlxG.log("> watch [Object.VariableName] (DisplayName)");
				case "unwatch":
					FlxG.log("> unwatch: Calls FlxG.unwatch()");
					FlxG.log("> unwatch [Object(.VariableName)]");
				default:
					FlxG.log("> help: Couldn't find command '" + Command + "'");
			}
		}
	}
	
	private function clearHistory():Void
	{
		_console.cmdHistory = new Array<String>();
		FlxG._game._prefsSave.flush();
		FlxG.log("> clearHistory: Command history cleared");
	}
	
	private function resetState():Void
	{
		FlxG.resetState();
		FlxG.log("> resetState: State has been reset");
		
		#if flash
		if (_console.autoPause) 
			FlxG._game.debugger.vcr.onStep();
		#end
	}
	
	private function switchState(ClassName:String):Void 
	{
		var instance:Dynamic = attemptToCreateInstance(ClassName, FlxState, "switchState");
		if (instance == null) 
			return;
		
		FlxG.switchState(instance);
		FlxG.log("> switchState: New '" + ClassName + "' created");  
		
		#if flash
		if (_console.autoPause)
			FlxG._game.debugger.vcr.onStep();
		#end
	}
	
	private function resetGame():Void
	{
		FlxG.resetGame();
		FlxG.log("> resetGame: Game has been reset");
		
		#if flash
		if (_console.autoPause)
			FlxG._game.debugger.vcr.onStep();
		#end
	}
	
	private function watchMouse():Void
	{
		if (!watchingMouse) {
			FlxG.watch(FlxG._game, "mouseX", "Mouse.x");
			FlxG.watch(FlxG._game, "mouseY", "Mouse.y");
			FlxG.log("> watchMouse: Mouse position added to watch window");
		}
		else {
			FlxG.unwatch(FlxG._game, "mouseX");
			FlxG.unwatch(FlxG._game, "mouseY");
			FlxG.log("> watchMouse: Mouse position removed from watch window");
		}
		
		watchingMouse = !watchingMouse;
	}
	
	private function visualDebug():Void
	{		
		FlxG.visualDebug = !FlxG.visualDebug;
		
		if (FlxG.visualDebug) 
			FlxG.log("> visualDebug: Enbaled");
		else
			FlxG.log("> visualDebug: Disabled");
	}
	
	private function pause():Void
	{
		if (FlxG._game.debugger.vcr.paused) {
			FlxG._game.debugger.vcr.onPlay();
			FlxG.log("> pause: Game unpaused");
		}
		else {
			FlxG._game.debugger.vcr.onPause();
			FlxG.log("> pause: Game paused");
		}
	}
	
	private function bgColor(Color:Dynamic):Void
	{
		var colorString:String = Std.string(Color);
		var color:Int = Std.parseInt(Color);
		
		if (colorString != null) {
			switch (colorString) {
				case "red":
					color = FlxG.RED;
				case "green":
					color = FlxG.GREEN;
				case "blue":
					color = FlxG.BLUE;
				case "pink":
					color = FlxG.PINK;
				case "white":
					color = FlxG.WHITE;
				case "black":
					color = FlxG.BLACK;
			}
		}
		
		if (!Math.isNaN(color)) {
			FlxG.bgColor = color;
			FlxG.log("> bgColor: Changed background color to '" + Color + "'");
		}
		else 
			FlxG.log("> bgColor: Invalid color '" + Color + "'");
	}
	
	private function shake(Intensity:Float = 0.05, Duration:Float = 0.5):Void
	{
		if (Math.isNaN(Intensity)) {
			FlxG.log("> shake: Intensity is not a number");
			return;
		}
		if (Math.isNaN(Duration)) {
			FlxG.log("> shake: Duration is not a number");
			return;
		}
		
		FlxG.shake(Intensity, Duration);
		FlxG.log("> shake: Shake started, Intensity: " + Intensity + " Duration: " + Duration);
	}
	
	private function close():Void
	{
		FlxG._game._debugger.visible = false;
		FlxG._game._debugger.hasMouse = false;
	}
	
	private function create(ClassName:String, X:Float = -1, Y:Float = -1):Void
	{
		if (Math.isNaN(X)) {
			FlxG.log("> create: X is not a number");
			return;
		}
		if (Math.isNaN(Y)) {
			FlxG.log("> create: Y is not a number");
			return;
		}
		
		var instance:Dynamic = attemptToCreateInstance(ClassName, FlxObject, "create");
		if (instance == null) 
			return;
		
		var obj:FlxObject = instance;
		if (X == -1) 
			obj.x = FlxG._game.mouseX;
		else 
			obj.x = X;
			
		if (Y == -1) 
			obj.y = FlxG._game.mouseY;
		else 
			obj.y = Y;
		
		FlxG.state.add(instance);
		FlxG.log("> create: New " + ClassName + " created at X = " + obj.x + " Y = " + obj.y);
		
		_console.objectStack.push(instance);
		_console.registerObject(Std.string(_console.objectStack.length), instance);
		
		FlxG.log("> create: " + ClassName + " registered as object '" + _console.objectStack.length + "'");
	}
	
	private function set(ObjectAndVariable:String, NewVariableValue:Dynamic, WatchName:String = null):Void
	{
		var info:Array<Dynamic> = resolveObjecAndVariable(ObjectAndVariable, "set");
		
		// In case resolving failed
		if (info == null)
			return;
			
		var object:Dynamic = info[0];
		var varName:String = info[1];
		var variable:Dynamic = Reflect.getProperty(object, varName);
		
		// Workaround to make Booleans work
		if (Std.is(variable, Bool)) {
			if (NewVariableValue == "false" || NewVariableValue == "0") 
				NewVariableValue = false;
			else if (NewVariableValue == "true" || NewVariableValue == "1") 
				NewVariableValue = true;
			else {
				FlxG.log("> set: '" + NewVariableValue + "' is not a valid value for Booelan '" + varName + "'");
				return;
			}
		}
		// Prevent turning numbers into NaN
		else if (Std.is(variable, Float) && Math.isNaN(Std.parseFloat(NewVariableValue))) {
			FlxG.log("> set: '" + NewVariableValue + "' is not a valid value for number '" + varName + "'");
			return;
		}
		// Prevent setting non "simple" typed properties
		else if (!Std.is(variable, Float) && !Std.is(variable, Bool) && !Std.is(variable, String))
		{
			FlxG.log("> set: '" + varName + ":" + Std.string(variable) + "' is not of a simple type (number, bool or string)");
			return;
		}
		
		Reflect.setProperty(object, varName, NewVariableValue);
		FlxG.log("> set: " + Std.string(object) + "." + varName + " is now " + NewVariableValue);
		
		if (WatchName != null) 
			FlxG.watch(object, varName, WatchName);
	}
	
	private function call(FunctionAlias:String, Params:Array<String>):Void
	{
		// Search for function in registeredFunctions hash
		var info:Array<Dynamic> = _console.registeredFunctions.get(FunctionAlias);
		var func:Dynamic = null;
		var obj:Dynamic = null;
		
		if (info != null)
		{
			// We found it!
			func = info[0];
			obj = info[1];
		}
		else
		{
			// Otherwise, we'll search for function in registeredObjects' methods
			var searchArr:Array<String> = FunctionAlias.split(".");
			var objectName:String = searchArr.shift();
			var object:Dynamic = _console.registeredObjects.get(objectName);
			
			if (!Reflect.isObject(object)) 
			{
				FlxG.log("> call: '" + Std.string(object) + "' is not a valid Object to call function from");
				return;
			}
			
			var tempObj:Dynamic = object;
			var tempVarName:String = "";
			var funcName:String = "";
			var l:Int = searchArr.length - 1;
			for (i in 0...l)
			{
				tempVarName = searchArr[i];
				if (!Reflect.hasField(tempObj, tempVarName)) 
				{
					FlxG.log("> call: " + Std.string(tempObj) + " does not have a field '" + tempVarName + "' to call function from");
					return;
				}
				
				tempObj = Reflect.getProperty(tempObj, tempVarName);
			}
			
			obj = tempObj;
			func = Reflect.field(tempObj, searchArr[l]);
			
			if (func == null)
			{
				FlxG.log("> call: " + Std.string(obj) + " does not have a method '" + searchArr[l] + "' to call");
				return;
			}
		}
		
		if (info == null && (func == null || obj == null)) 
		{
			FlxG.log("> call: '" + FunctionAlias + "' is not a registered function");
			return;
		}
		
		if (Reflect.isFunction(func)) {
			_console.callFunction(obj, func, Params);
			if (Params == []) 
				FlxG.log("> call: Called '" + FunctionAlias + "'");
			else 
				FlxG.log("> call: Called '" + FunctionAlias + "' with params " + Params);

		}
		else {
			FlxG.log("> call: '" + FunctionAlias + "' is not a valid function of object '" + Std.string(obj) + "'");
		}
	}
	
	private function listObjects():Void
	{
		FlxG.log(">> Objects registered <<"); 
		listHash(_console.registeredObjects);
	}
	
	private function listFunctions():Void
	{
		FlxG.log(">> Functions registered <<"); 
		listHash(_console.registeredFunctions);
	}
	
	private function watch(ObjectAndVariable:String, DisplayName:String = null):Void
	{
		var info:Array<Dynamic> = resolveObjecAndVariable(ObjectAndVariable, "watch");
		
		// In case resolving failed
		if (info == null)
			return;
			
		var object:Dynamic = info[0];
		var varName:String = info[1];
		
		FlxG.watch(object, varName);
	}
	
	private function unwatch(ObjectAndVariable:String, VariableName:String = null):Void
	{
		var info:Array<Dynamic> = resolveObjecAndVariable(ObjectAndVariable, "watch");
		
		// In case resolving failed
		if (info == null)
			return;
			
		var object:Dynamic = info[0];
		var varName:String = info[1];
		
		FlxG.unwatch(object, varName);
	}
	
	/**
	 * Helper functions
	 */
	
	private function attemptToCreateInstance(ClassName:String, _Type:Dynamic, CommandName:String):Dynamic
	{
		var obj:Dynamic = Type.resolveClass(ClassName);
		if (!Reflect.isObject(obj)) {
			FlxG.log("> " + CommandName + ": '" + ClassName + "' is not a valid class name. Try passing the full class path. Also make sure the class is being compiled.");
			return null;
		}
		
		var instance:Dynamic = Type.createInstance(obj, []);
		
		if (!Std.is(instance, _Type)) {
			FlxG.log("> " + CommandName + ": '" + ClassName + "' is not a " + Type.getClassName(_Type));
			return null;
		}
		
		return instance;
	}
	
	private function listHash(hash:Hash<Dynamic>) 
	{
		var output:String = "";
		
		for (key in hash.keys()) {
			output += key;
			output += ", ";
		}
		output = output.substring(0, output.length - 2);
		
		FlxG.log(output);
	}
	
	private function resolveObjecAndVariable(ObjectAndVariable:String, CommandName:String):Array<Dynamic>
	{
		var searchArr:Array<String> = ObjectAndVariable.split(".");
		
		// In case there's not dot in the string
		if (searchArr[0].length == ObjectAndVariable.length) {
			FlxG.log("> " + CommandName + ": '" + ObjectAndVariable + "' does not refer to an object's field");
			return null;
		}
		
		var object:Dynamic = _console.registeredObjects.get(searchArr.shift());
		var variableName:String = searchArr.join(".");
		
		if (!Reflect.isObject(object)) {
			FlxG.log("> " + CommandName + ": '" + Std.string(object) + "' is not a valid Object");
			return null;
		}
		
		// Searching for property...
		var l:Int = searchArr.length;
		var tempObj:Dynamic = object;
		var tempVarName:String = "";
		for (i in 0...l)
		{
			tempVarName = searchArr[i];
			if (!Reflect.hasField(tempObj, tempVarName)) 
			{
				FlxG.log("> " + CommandName + ": " + Std.string(tempObj) + " does not have a field '" + tempVarName + "'");
				return null;
			}
			
			if (i < (l - 1))
			{
				tempObj = Reflect.getProperty(tempObj, tempVarName);
			}
		}
		
		return [tempObj, tempVarName];
	}
}