package org.flixel.system.debug;

import nme.display.GradientType;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxState;

class Commands
{
	private var _console:Console;
	private var watchingMouse:Bool = false;
	
	public function new(console:Console):Void
	{
		_console = console;
		
		// Install commands
		console.addCommand("help", this, help, "h");
		console.addCommand("log", FlxG, FlxG.log);
		console.addCommand("clearLog", FlxG, FlxG.clearLog);
		console.addCommand("clear", FlxG, FlxG.clearLog, "cl");
		console.addCommand("clearHistory", this, clearHistory, "ch");
		console.addCommand("resetState", this, resetState, "rs");
		console.addCommand("switchState", this, switchState, "ss");
		console.addCommand("resetGame", FlxG, FlxG.resetGame, "rg");
		#if flash
		console.addCommand("fullscreen", FlxG, FlxG.fullscreen, "fs");
		#end
		console.addCommand("watchMouse", this, watchMouse, "wm");
		console.addCommand("visualDebug", this, visualDebug, "vd");
		console.addCommand("play", FlxG, FlxG.play, "p");
		console.addCommand("playMusic", FlxG, FlxG.playMusic, "pm");
		console.addCommand("bgColor", this, bgColor, "bg");
		console.addCommand("pauseSounds", this, pauseSounds);
		console.addCommand("resumeSounds", this, resumeSounds);
		console.addCommand("shake", this, shake, "sh");
		console.addCommand("volume", this, volume, "vl");
		console.addCommand("close", this, close);
		console.addCommand("create", this, create, "cr");
		console.addCommand("set", this, set);
	}
	
		private function help():Void
	{
		FlxG.log("------------------------------------------------------------------------");
		FlxG.log("|                          List of system commands:                          |" );
		FlxG.log("------------------------------------------------------------------------");
		FlxG.log("| > log [Text:String]");
		FlxG.log("| > clearLog | clear | cl");
		FlxG.log("| > clearHistory | ch");
		FlxG.log("| > help | h");
		FlxG.log("| > resetState | rs");
		FlxG.log("| > switchState | ss [State:FlxState]");
		FlxG.log("| > resetGame | rs");
		#if flash
		FlxG.log("| > fullscreen | fs");
		#end
		FlxG.log("| > watchMouse | wm (toggle)");
		FlxG.log("| > visualDebug | vd (toggle)");
		FlxG.log("| > play | p [Sound:Dynamic] [Volume:Float = 1]");
		FlxG.log("| > playMusic | pm [Sound:Dynamic] [Volume:Float = 1]");
		FlxG.log("| > bgColor | bg [Color:UInt or color from FlxG]");
		FlxG.log("| > pauseSounds");
		FlxG.log("| > resumeSounds");
		FlxG.log("| > shake | sh [Intensity:Float = 0.05] [Duration:Float = 0.5]");
		FlxG.log("| > volume | vl [Volume:Float]");
		FlxG.log("| > create | cr [Object:FlxObject] [X:Float = FlxG.mouse.x] [Y:Float = FlxG.mouse.y]");
		FlxG.log("| > set [Object] [Variable] [NewValue:Dynamic]");
		FlxG.log("| > close | cl");
		FlxG.log("------------------------------------------------------------------------");
	}
	
	private function clearHistory():Void
	{
		_console.commandHistory = new Array<String>();
		_console._shared.flush();
		FlxG.log("> clearHistory: Command history cleared");
	}
	
	private function resetState():Void
	{
		FlxG.resetState();
		FlxG.log("> resetState: State has been reset");
	}
	
	private function switchState(ClassName:String):Void 
	{
		var instance:Dynamic = attemptToCreateInstance(ClassName, FlxState, "switchState");
		if (instance == null) 
			return;
		
		FlxG.switchState(instance);
		FlxG.log("> switchState: New '" + ClassName + "' created");  
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
	
	private function bgColor(Color:Dynamic):Void
	{
		var colorString:String = cast(Color);
		var color:Int;
		if (Std.parseInt(Color) == null) 
			color = -1;
		else 
			color = Std.parseInt(Color);
		
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
	
		if (color != -1) {
			FlxG.bgColor = color;
			FlxG.log("> bgColor: Changed background color to '" + Color + "'");
		}
		else 
			FlxG.log("> bgColor: Invalid color '" + Color + "'");
	}
	
	private function pauseSounds():Void
	{
		FlxG.pauseSounds();
		FlxG.log("> pauseSounds: Sounds paused");
	}
	
	private function resumeSounds():Void
	{
		FlxG.resumeSounds();
		FlxG.log("> resumeSounds: Sounds resumed");
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
	
	private function volume(Volume:Float):Void
	{
		if (Math.isNaN(Volume)) {
			FlxG.log("> volume: Volume passed is not a number");
			return;
		}
		
		FlxG.volume = Volume;
		FlxG.log("> volume: Volume changed to " + FlxG.volume);
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
		
		var obj:FlxObject = cast(instance);
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
	}
	
	private function set(AnyObject:Dynamic, VariableName:String, NewValue:Dynamic):Void
	{
		// Shortcut to access current state
		if (Std.string(AnyObject) == "state") 
			AnyObject = FlxG.state;
		// Shortcut to access FlxG which would be org.flixel.FlxG normally	
		else if (Std.string(AnyObject) == "FlxG") 
			AnyObject = FlxG;
		// Turn string into actual object
		else
			AnyObject = Type.resolveClass(AnyObject);
			
		if (!Reflect.isObject(AnyObject)) {
			FlxG.log("> set: '" + Std.string(AnyObject) + "' is not a valid Object");
			return;
		}
		
		if (!Reflect.hasField(AnyObject, VariableName)) {
			FlxG.log("> set: " + Std.string(AnyObject) + " does not have a field '" + VariableName + "'");
			return;
		}
		
		Reflect.setField(AnyObject, VariableName, NewValue);
		
		FlxG.log("> set: " + Std.string(AnyObject) + "." + VariableName + " is now " + NewValue);
	}
	
	// Helper functions
	
	private function attemptToCreateInstance(ClassName:String, _Type:Dynamic, CommandName:String):Dynamic
	{
		var obj:Dynamic = Type.resolveClass(ClassName);
		if (!Reflect.isObject(obj)) {
			FlxG.log("> " + CommandName + ": '" + ClassName + "' is not a valid class name. Try passing the full class path.");
			return null;
		}
		
		var instance:Dynamic = Type.createInstance(obj, []);
		
		if (!Std.is(instance, _Type)) {
			FlxG.log("> " + CommandName + ": '" + ClassName + "' is not a " + Type.getClassName(_Type));
			return null;
		}
		
		return instance;
	}
}