package flixel.system.debug;

<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxState;

#if haxe3
private typedef Hash<T> = Map<String,T>;
#end
=======
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental

class ConsoleCommands
{
	private var _console:Console;
	private var watchingMouse:Bool = false;
	
	public function new(console:Console):Void
	{
		_console = console;
		
		// Install commands
		console.addCommand("help", this, help, "h");
		console.addCommand("log", FlxG, FlxG.log.add);
		console.addCommand("clearLog", FlxG, FlxG.log.clear, "clear");
		console.addCommand("clearHistory", this, clearHistory, "ch");
		console.addCommand("resetState", this, resetState, "rs");
		console.addCommand("switchState", this, switchState, "ss");
		console.addCommand("resetGame", this, resetGame, "rg");
		#if flash
		console.addCommand("fullscreen", FlxG, FlxG.cameras.fullscreen, "fs");
		#end
		console.addCommand("watchMouse", this, watchMouse, "wm");
		console.addCommand("visualDebug", this, visualDebug, "vd");
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
		console.addCommand("pause", this, pause);
		console.addCommand("play", FlxG, FlxG.play, "p");
		console.addCommand("playMusic", FlxG, FlxG.playMusic, "pm");
=======
		console.addCommand("pause", this, pause, "p");
		console.addCommand("play", FlxG, FlxG.sound.play);
		console.addCommand("playMusic", FlxG, FlxG.sound.playMusic, "pm");
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
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
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
=======
		#end
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
	}
	
	private function help(Command:String = ""):Void
	{
		if (Command == "") {
			// Don't include the fullscreen command for non-flash targets
			var fs:String = "";
			#if flash
			fs = "fullscreen,";
			#end
			
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
			FlxG.log(">> System commands << \nlog, clearLog, clearHistory, help, resetState, switchState, resetGame, " + fs + " watchMouse, visualDebug, pause, play, playMusic, bgColor, shake, create, set, call, close, listObjects, listFunctions");
=======
			cLog("System commands: \nlog, clearLog, clearHistory, help, resetState, switchState, resetGame, " + fs + " watchMouse, visualDebug, pause, play, playMusic, bgColor, shake, create, set, call, close, listObjects, listFunctions, watch, unwatch");
			cLog("help (Command) for more information about a specific command"); 
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
		}
		else {
			switch (Command) {
				case "log":
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
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
=======
					cLog("log: Calls FlxG.log.add() with the text you enter");
					cLog("log [Text]");
				case "clearLog", "clear":
					cLog("clearLog: {clear} Clears the log window");
				case "clearHistory", "ch":
					cLog("clearHistory: {ch} Clears the command history");
				case "help", "h":
					cLog("help: {h} Lists all system commands or provides more info on a specified command");
					cLog("help (Command)");
				case "resetState", "rs":
					cLog("resetState: {rs} Calls FlxG.resetState()");
				case "resetGame", "rg":
					cLog("resetGame: {rg} Calls FlxG.resetGame()");
				case "switchState", "ss":
					cLog("switchState: {ss} Calls FlxG.switchState() with specified FlxState");
					cLog("switchState [FlxState]");
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
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
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
		FlxG._game._prefsSave.flush();
		FlxG.log("> clearHistory: Command history cleared");
=======
		FlxG.game.prefsSave.flush();
		cLog("clearHistory: Command history cleared");
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
	}
	
	private function resetState():Void
	{
		FlxG.resetState();
		FlxG.log("> resetState: State has been reset");
		
		#if flash
		if (_console.autoPause) 
			FlxG.game.debugger.vcr.onStep();
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
			FlxG.game.debugger.vcr.onStep();
		#end
	}
	
	private function resetGame():Void
	{
		FlxG.resetGame();
		FlxG.log("> resetGame: Game has been reset");
		
		#if flash
		if (_console.autoPause)
			FlxG.game.debugger.vcr.onStep();
		#end
	}
	
	private function watchMouse():Void
	{
		if (!watchingMouse) {
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
			FlxG.watch(FlxG._game, "mouseX", "Mouse.x");
			FlxG.watch(FlxG._game, "mouseY", "Mouse.y");
			FlxG.log("> watchMouse: Mouse position added to watch window");
		}
		else {
			FlxG.unwatch(FlxG._game, "mouseX");
			FlxG.unwatch(FlxG._game, "mouseY");
			FlxG.log("> watchMouse: Mouse position removed from watch window");
=======
			// TODO: turn this into quickWatch to display both in one watch entry.
			FlxG.watch.add(FlxG.game, "mouseX", "Mouse.x");
			FlxG.watch.add(FlxG.game, "mouseY", "Mouse.y");
			cLog("watchMouse: Mouse position added to watch window");
		}
		else {
			FlxG.watch.remove(FlxG.game, "mouseX");
			FlxG.watch.remove(FlxG.game, "mouseY");
			cLog("watchMouse: Mouse position removed from watch window");
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
		}
		
		watchingMouse = !watchingMouse;
	}
	
	private function visualDebug():Void
	{		
		FlxG.debugger.visualDebug = !FlxG.debugger.visualDebug;
		
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
		if (FlxG.visualDebug) 
			FlxG.log("> visualDebug: Enbaled");
=======
		if (FlxG.debugger.visualDebug) 
			cLog("visualDebug: Enbaled");
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
		else
			FlxG.log("> visualDebug: Disabled");
	}
	
	private function pause():Void
	{
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
		if (FlxG._game.debugger.vcr.paused) {
			FlxG._game.debugger.vcr.onPlay();
			FlxG.log("> pause: Game unpaused");
		}
		else {
			FlxG._game.debugger.vcr.onPause();
			FlxG.log("> pause: Game paused");
=======
		if (FlxG.game.debugger.vcr.paused) {
			FlxG.game.debugger.vcr.onPlay();
			cLog("pause: Game unpaused");
		}
		else {
			FlxG.game.debugger.vcr.onPause();
			cLog("pause: Game paused");
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
		}
	}
	
	private function bgColor(Color:Dynamic):Void
	{
		var colorString:String = Std.string(Color);
		var color:Int = Std.parseInt(Color);
		
		if (colorString != null) {
			switch (colorString) {
				case "red":
					color = FlxColor.RED;
				case "green":
					color = FlxColor.GREEN;
				case "blue":
					color = FlxColor.BLUE;
				case "pink":
					color = FlxColor.PINK;
				case "white":
					color = FlxColor.WHITE;
				case "black":
					color = FlxColor.BLACK;
			}
		}
		
		if (!Math.isNaN(color)) {
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
			FlxG.bgColor = color;
			FlxG.log("> bgColor: Changed background color to '" + Color + "'");
=======
			FlxG.cameras.bgColor = color;
			cLog("bgColor: Changed background color to '" + Color + "'");
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
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
		
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
		FlxG.shake(Intensity, Duration);
		FlxG.log("> shake: Shake started, Intensity: " + Intensity + " Duration: " + Duration);
=======
		FlxG.cameraFX.shake(Intensity, Duration);
		cLog("shake: Shake started, Intensity: " + Intensity + " Duration: " + Duration);
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
	}
	
	private function close():Void
	{
		FlxG.debugger.visible = false;
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
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
		if (X == -1) 
			obj.x = FlxG._game.mouseX;
		else 
			obj.x = X;
			
		if (Y == -1) 
			obj.y = FlxG._game.mouseY;
		else 
			obj.y = Y;
=======
		
		if (MousePos) {
			obj.x = FlxG.game.mouseX;
			obj.y = FlxG.game.mouseY;
		}
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
		
		FlxG.state.add(instance);
		FlxG.log("> create: New " + ClassName + " created at X = " + obj.x + " Y = " + obj.y);
		
		_console.objectStack.push(instance);
		_console.registerObject(Std.string(_console.objectStack.length), instance);
		
		FlxG.log("> create: " + ClassName + " registered as object '" + _console.objectStack.length + "'");
	}
	
	private function set(ObjectAlias:String, VariableName:String, NewValue:Dynamic):Void
	{
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
		var object:Dynamic = _console.registeredObjects.get(ObjectAlias);
=======
		var info:Array<Dynamic> = resolveObjectAndVariable(ObjectAndVariable, "set");
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
		
		if (!Reflect.isObject(object)) {
			FlxG.log("> set: '" + Std.string(object) + "' is not a valid Object");
			return;
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
		}
		
		if (!Reflect.hasField(object, VariableName)) {
			FlxG.log("> set: " + Std.string(object) + " does not have a field '" + VariableName + "'");
			return;
		}
		
		var variable:Dynamic = Reflect.field(object, VariableName);
=======
			
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
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
		
		// Workaround to make Booleans work
		if (Std.is(variable, Bool)) {
			if (NewValue == "false" || NewValue == "0") 
				NewValue = false;
			else if (NewValue == "true" || NewValue == "1") 
				NewValue = true;
			else {
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
				FlxG.log("> set: '" + NewValue + "' is not a valid value for Booelan '" + VariableName + "'");
=======
				FlxG.log.error("set: '" + NewVariableValue + "' is not a valid value for Booelan '" + varName + "'");
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
				return;
			}
		}
		// Prevent turning numbers into NaN
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
		else if (Std.is(variable, Float) && Math.isNaN(Std.parseFloat(NewValue))) {
			FlxG.log("> set: '" + NewValue + "' is not a valid value for number '" + VariableName + "'");
=======
		else if (Std.is(variable, Float) && Math.isNaN(Std.parseFloat(NewVariableValue))) {
			FlxG.log.error("set: '" + NewVariableValue + "' is not a valid value for number '" + varName + "'");
			return;
		}
		// Prevent setting non "simple" typed properties
		else if (!Std.is(variable, Float) && !Std.is(variable, Bool) && !Std.is(variable, String))
		{
			FlxG.log.error("set: '" + varName + ":" + Std.string(variable) + "' is not of a simple type (number, bool or string)");
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
			return;
		}
		
		Reflect.setProperty(object, VariableName, NewValue);
		
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
		FlxG.log("> set: " + Std.string(object) + "." + VariableName + " is now " + NewValue);
=======
		if (WatchName != null) 
			FlxG.watch.add(object, varName, WatchName);
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
	}
	
	private function call(FunctionAlias:String, Params:Array<String>):Void
	{
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
		var info:Array<Dynamic> = _console.registeredFunctions.get(FunctionAlias);
		if (info == null) {
			FlxG.log("> call: '" + FunctionAlias + "' is not a registered function");
			return;
=======
		if (Params == null)
			Params = [];
			
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
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
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
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
			FlxG.log("> call: '" + FunctionAlias + "' is not a valid function of object '" + Std.string(obj) + "'");
=======
			FlxG.log.error("call: '" + FunctionAlias + "' is not a valid function");
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
		}
	}
	
	private function listObjects():Void
	{
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
		FlxG.log(">> Objects registered <<"); 
		listHash(_console.registeredObjects);
=======
		cLog("Objects registered: \n" + FlxStringUtil.formatStringMap(_console.registeredObjects)); 
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
	}
	
	private function listFunctions():Void
	{
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
		FlxG.log(">> Functions registered <<"); 
		listHash(_console.registeredFunctions);
=======
		cLog("Functions registered: \n" + FlxStringUtil.formatStringMap(_console.registeredFunctions)); 
	}
	
	private function watch(ObjectAndVariable:String, DisplayName:String = null):Void
	{
		var info:Array<Dynamic> = resolveObjectAndVariable(ObjectAndVariable, "watch");
		
		// In case resolving failed
		if (info == null)
			return;
			
		var object:Dynamic = info[0];
		var varName:String = info[1];
		
		FlxG.watch.add(object, varName);
	}
	
	private function unwatch(ObjectAndVariable:String, VariableName:String = null):Void
	{
		var info:Array<Dynamic> = resolveObjectAndVariable(ObjectAndVariable, "watch");
		
		// In case resolving failed
		if (info == null)
			return;
			
		var object:Dynamic = info[0];
		var varName:String = info[1];
		
		FlxG.watch.remove(object, varName);
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
	}
	
	/**
	 * Helper functions
	 */
	
	private function attemptToCreateInstance(ClassName:String, _Type:Dynamic, CommandName:String):Dynamic
	{
		var obj:Dynamic = Type.resolveClass(ClassName);
		if (!Reflect.isObject(obj)) {
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
			FlxG.log("> " + CommandName + ": '" + ClassName + "' is not a valid class name. Try passing the full class path. Also make sure the class is being compiled.");
=======
			FlxG.log.error(CommandName + ": '" + ClassName + "' is not a valid class name. Try passing the full class path. Also make sure the class is being compiled.");
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
			return null;
		}
		
		var instance:Dynamic = Type.createInstance(obj, []);
		
		if (!Std.is(instance, _Type)) {
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
			FlxG.log("> " + CommandName + ": '" + ClassName + "' is not a " + Type.getClassName(_Type));
=======
			FlxG.log.error(CommandName + ": '" + ClassName + "' is not a " + Type.getClassName(_Type));
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
			return null;
		}
		
		return instance;
	}
	
<<<<<<< HEAD:src/org/flixel/system/debug/ConsoleCommands.hx
	private function listHash(hash:Hash<Dynamic>) 
	{
		var output:String = "";
		
		for (key in hash.keys()) {
			output += key;
			output += ", ";
		}
		output = output.substring(0, output.length - 2);
		
		FlxG.log(output);
=======
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
	
	private function cLog(Text:Dynamic):Void
	{
		FlxG.log.advanced([Text], Log.STYLE_CONSOLE);
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/debug/ConsoleCommands.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/debug/ConsoleCommands.hx
>>>>>>> experimental
	}
}
