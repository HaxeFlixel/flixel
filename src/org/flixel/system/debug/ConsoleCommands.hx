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
					FlxG.log("> set: Changes a var within a previosuly registered object via FlxG.console.registerObject");
					FlxG.log("> set [Object] [VariableName] [NewValue]");
				case "call":
					FlxG.log("> call: Calls a function previously registered via FlxG.console.registerFunction with a set of params");
					FlxG.log("> call [Function] [param0...paramX]");
				case "listObjects":
					FlxG.log("> listObjects: Lists all the aliases of the objects registered");
				case "listFunctions":
					FlxG.log("> listFunctions: Lists all the aliases of the functions registered");
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
	
	private function set(ObjectAlias:String, VariableName:String, NewValue:Dynamic):Void
	{
		var tempArr1:Array<String> = ObjectAlias.split(".");
		var object:Dynamic = _console.registeredObjects.get(tempArr1.shift());
		
		if (!Reflect.isObject(object)) {
			FlxG.log("> set: '" + Std.string(object) + "' is not a valid Object");
			return;
		}
		
		var tempArr2:Array<String> = VariableName.split(".");
		var searchArr:Array<String> = tempArr1.concat(tempArr2);
		
		// Searching for property...
		var l:Int = searchArr.length;
		var tempObj:Dynamic = object;
		var tempVarName:String = "";
		for (i in 0...l)
		{
			tempVarName = searchArr[i];
			if (!Reflect.hasField(object, tempVarName)) 
			{
				FlxG.log("> set: " + Std.string(tempObj) + " does not have a field '" + tempVarName + "'");
				return;
			}
			
			if (i < (l - 1))
			{
				tempObj = Reflect.field(tempObj, tempVarName);
			}
		}
		
		object = tempObj;
		var variable:Dynamic = Reflect.field(object, tempVarName);
		
		// Workaround to make Booleans work
		if (Std.is(variable, Bool)) {
			if (NewValue == "false" || NewValue == "0") 
				NewValue = false;
			else if (NewValue == "true" || NewValue == "1") 
				NewValue = true;
			else {
				FlxG.log("> set: '" + NewValue + "' is not a valid value for Booelan '" + VariableName + "'");
				return;
			}
		}
		// Prevent turning numbers into NaN
		else if (Std.is(variable, Float) && Math.isNaN(Std.parseFloat(NewValue))) {
			FlxG.log("> set: '" + NewValue + "' is not a valid value for number '" + VariableName + "'");
			return;
		}
		// Prevent setting non "simple" typed properties
		else if (!Std.is(variable, Float) && !Std.is(variable, Bool) && !Std.is(variable, String))
		{
			FlxG.log("> set: '" + VariableName + ":" + Std.string(variable) + "' is not of a simple type (number, bool or string)");
			return;
		}
		
		Reflect.setProperty(object, tempVarName, NewValue);
		
		FlxG.log("> set: " + Std.string(object) + "." + tempVarName + " is now " + NewValue);
	}
	
	
	
	private function call(FunctionAlias:String, Params:Array<String>):Void
	{
		var info:Array<Dynamic> = _console.registeredFunctions.get(FunctionAlias);
		if (info == null) {
			FlxG.log("> call: '" + FunctionAlias + "' is not a registered function");
			return;
		}
			
		var func:Dynamic = info[0];
		var obj:Dynamic = info[1];
		
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
}