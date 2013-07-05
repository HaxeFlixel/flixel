package flixel.system.debug;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

class ConsoleCommands
{
	private var _console:Console;
	private var watchingMouse:Bool = false;
	
	public function new(console:Console):Void
	{
		#if !FLX_NO_DEBUG
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
		console.addCommand("pause", this, pause, "p");
		console.addCommand("play", FlxG, FlxG.sound.play);
		console.addCommand("playMusic", FlxG, FlxG.sound.playMusic, "pm");
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
		#end
	}
	
	#if !FLX_NO_DEBUG
	private function help(Command:String = ""):Void
	{
		if (Command == "") {
			// Don't include the fullscreen command for non-flash targets
			var fs:String = "";
			#if flash
			fs = "fullscreen,";
			#end
			
			cLog("System commands: \nlog, clearLog, clearHistory, help, resetState, switchState, resetGame, " + fs + " watchMouse, visualDebug, pause, play, playMusic, bgColor, shake, create, set, call, close, listObjects, listFunctions, watch, unwatch");
			cLog("help (Command) for more information about a specific command"); 
		}
		else {
			cLog("help: " + Command);
			
			switch (Command) {
				case "log":
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
				#if flash
				case "fullscreen", "fs":
					cLog("fullscreen: {fs} Enables fullscreen mode");
				#end
				case "watchMouse", "wm":
					cLog("watchMouse: {wm} Adds the x and y pos of the mosue to the watch window. Super useful for GUI-Building stuff.");
				case "visualDebug", "vd":
					cLog("visualDebug: {vd} Toggles visual debugging");
				case "pause", "p":
					cLog("pause: {p} Pauses / unpauses the game");
				case "play":
					cLog("play: Plays a sound");
					cLog("play [Sound] (Volume = 1)");
				case "playMusic", "pm":
					cLog("playMusic: {pm} Sets up and plays a looping background soundtrack.");
					cLog("playMusic [Music] (Volume = 1)");
				case "bgColor", "bg":
					cLog("bgColor: {bg} Changes the background color to a specified color. You can also pass the colors 'red, green, blue, pink, white,  and black'");
					cLog("bgColor [Color]");
				case "shake", "sh":
					cLog("shake: {sh} Calls FlxG.shake()");
					cLog("shake (Intensity = 0.05) (Duration = 0.5)");
				case "close", "cl":
					cLog("close: {cl} Close the debugger overlay");
				case "create", "cr": 
					cLog("create: {cr} Creates a new FlxObject and registers it - by default at the mouse position.");
					cLog("create [FlxObject] (MousePos = true) (param0...paramX)");
				case "set":
					cLog("set: Changes a var within a previosuly registered object via FlxG.console.registerObject(). Supports nesting (a field within an object within a registered object). Set a WatchName if you want to add the var to the watch window.");
					cLog("set [Object.VariableName] [NewValue] (WatchName)");
				case "call":
					cLog("call: Calls a function previously registered via FlxG.console.registerFunction() with a set of params (or a function of a registered object");
					cLog("call [(Object.)Function] [param0...paramX]");
				case "listObjects", "lo":
					cLog("listObjects: {lo} Lists all the aliases of the objects registered");
				case "listFunctions", "lf":
					cLog("listFunctions: {lf} Lists all the aliases of the functions registered");
				case "watch", "w":
					cLog("watch: {w} Calls FlxG.watch()");
					cLog("watch [Object.VariableName] (DisplayName)");
				case "unwatch", "uw":
					cLog("unwatch: {uw} Calls FlxG.unwatch()");
					cLog("unwatch [Object(.VariableName)]");
				default:
					cLog("help: Couldn't find command '" + Command + "'");
			}
			
			cLog("{shortcut} [required param] (optional param)");
		}
	}
	
	private function clearHistory():Void
	{
		_console.cmdHistory = new Array<String>();
		FlxG._game._prefsSave.flush();
		cLog("clearHistory: Command history cleared");
	}
	
	private function resetState():Void
	{
		FlxG.resetState();
		cLog("resetState: State has been reset");
		
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
		cLog("switchState: New '" + ClassName + "' created");  
		
		#if flash
		if (_console.autoPause)
			FlxG._game.debugger.vcr.onStep();
		#end
	}
	
	private function resetGame():Void
	{
		FlxG.resetGame();
		cLog("resetGame: Game has been reset");
		
		#if flash
		if (_console.autoPause)
			FlxG._game.debugger.vcr.onStep();
		#end
	}
	
	private function watchMouse():Void
	{
		if (!watchingMouse) {
			// TODO: turn this into quickWatch to display both in one watch entry.
			FlxG.watch.add(FlxG._game, "mouseX", "Mouse.x");
			FlxG.watch.add(FlxG._game, "mouseY", "Mouse.y");
			cLog("watchMouse: Mouse position added to watch window");
		}
		else {
			FlxG.watch.remove(FlxG._game, "mouseX");
			FlxG.watch.remove(FlxG._game, "mouseY");
			cLog("watchMouse: Mouse position removed from watch window");
		}
		
		watchingMouse = !watchingMouse;
	}
	
	private function visualDebug():Void
	{		
		FlxG.debugger.visualDebug = !FlxG.debugger.visualDebug;
		
		if (FlxG.debugger.visualDebug) 
			cLog("visualDebug: Enbaled");
		else
			cLog("visualDebug: Disabled");
	}
	
	private function pause():Void
	{
		if (FlxG._game.debugger.vcr.paused) {
			FlxG._game.debugger.vcr.onPlay();
			cLog("pause: Game unpaused");
		}
		else {
			FlxG._game.debugger.vcr.onPause();
			cLog("pause: Game paused");
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
			FlxG.cameras.bgColor = color;
			cLog("bgColor: Changed background color to '" + Color + "'");
		}
		else 
			cLog("bgColor: Invalid color '" + Color + "'");
	}
	
	private function shake(Intensity:Float = 0.05, Duration:Float = 0.5):Void
	{
		if (Math.isNaN(Intensity)) {
			cLog("shake: Intensity is not a number");
			return;
		}
		if (Math.isNaN(Duration)) {
			cLog("shake: Duration is not a number");
			return;
		}
		
		FlxG.cameraFX.shake(Intensity, Duration);
		cLog("shake: Shake started, Intensity: " + Intensity + " Duration: " + Duration);
	}
	
	private function close():Void
	{
		FlxG.debugger.visible = false;
	}
	
	private function create(ClassName:String, MousePos:Bool = true, Params:Array<String> = null):Void
	{
		if (Params == null)
			Params = [];
			
		var instance:Dynamic = attemptToCreateInstance(ClassName, FlxObject, "create", Params);
		if (instance == null) 
			return;
		
		var obj:FlxObject = instance;
		
		if (MousePos) {
			obj.x = FlxG._game.mouseX;
			obj.y = FlxG._game.mouseY;
		}
		
		FlxG.state.add(instance);
		
		if (Params.length == 0)
			cLog("create: New " + ClassName + " created at X = " + obj.x + " Y = " + obj.y);
		else 
			cLog("create: New " + ClassName + " created at X = " + obj.x + " Y = " + obj.y + " with params " + Params);
			
		_console.objectStack.push(instance);
		_console.registerObject(Std.string(_console.objectStack.length), instance);
		
		cLog("create: " + ClassName + " registered as object '" + _console.objectStack.length);
	}
	
	private function set(ObjectAndVariable:String, NewVariableValue:Dynamic, WatchName:String = null):Void
	{
		var info:Array<Dynamic> = resolveObjectAndVariable(ObjectAndVariable, "set");
		
		// In case resolving failed
		if (info == null)
			return;
			
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
		if (Std.is(variable, Bool)) {
			if (NewVariableValue == "false" || NewVariableValue == "0") 
				NewVariableValue = false;
			else if (NewVariableValue == "true" || NewVariableValue == "1") 
				NewVariableValue = true;
			else {
				FlxG.log.error("set: '" + NewVariableValue + "' is not a valid value for Booelan '" + varName + "'");
				return;
			}
		}
		// Prevent turning numbers into NaN
		else if (Std.is(variable, Float) && Math.isNaN(Std.parseFloat(NewVariableValue))) {
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
		
		if (WatchName != null) 
			FlxG.watch.add(object, varName, WatchName);
	}
	
	private function call(FunctionAlias:String, Params:Array<String> = null):Void
	{
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
		}
		
		if (Reflect.isFunction(func)) {
			var success:Bool = _console.callFunction(null, func, Params);
			
			if (Params.length == 0 && success) 
				cLog("call: Called '" + FunctionAlias + "'");
			else if (success)
				cLog("call: Called '" + FunctionAlias + "' with params " + Params);
		}
		else {
			FlxG.log.error("call: '" + FunctionAlias + "' is not a valid function");
		}
	}
	
	private function listObjects():Void
	{
		cLog("Objects registered: \n" + FlxStringUtil.formatStringMap(_console.registeredObjects)); 
	}
	
	private function listFunctions():Void
	{
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
	}
	
	/**
	 * Helper functions
	 */
	
	private function attemptToCreateInstance(ClassName:String, _Type:Dynamic, CommandName:String, Params:Array<String> = null):Dynamic
	{
		if (Params == null) 
			Params = [];
			
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
	
	private function cLog(Text:Dynamic):Void
	{
		FlxG.log.advanced([Text], Log.STYLE_CONSOLE);
	}
	#end
}