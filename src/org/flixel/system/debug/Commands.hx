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
		console.addCommand("help", this, help);
		console.addCommand("log", FlxG, FlxG.log);
		console.addCommand("clearLog", FlxG, FlxG.clearLog);
		console.addCommand("clear", FlxG, FlxG.clearLog);
		console.addCommand("clearHistory", this, clearHistory);
		console.addCommand("resetState", this, resetState);
		console.addCommand("switchState", this, switchState);
		console.addCommand("resetGame", FlxG, FlxG.resetGame);
		#if flash
		console.addCommand("fullscreen", FlxG, FlxG.fullscreen);
		#end
		console.addCommand("watchMouse", this, watchMouse);
		console.addCommand("visualDebug", this, visualDebug);
		console.addCommand("play", FlxG, FlxG.play);
		console.addCommand("playMusic", FlxG, FlxG.playMusic);
		console.addCommand("bgColor", this, bgColor);
		console.addCommand("pauseSounds", this, pauseSounds);
		console.addCommand("resumeSounds", this, resumeSounds);
		console.addCommand("shake", this, shake);
		console.addCommand("volume", this, volume);
		console.addCommand("close", this, close);
		console.addCommand("create", this, create);
		console.addCommand("set", this, set);
	}
	
		private function help():Void
	{
		FlxG.log("------------------------------------------------------------------------");
		FlxG.log("|                          List of system commands:                          |" );
		FlxG.log("------------------------------------------------------------------------");
		FlxG.log("| > log [Text:String]");
		FlxG.log("| > clearLog | clear");
		FlxG.log("| > clearHistory");
		FlxG.log("| > help");
		FlxG.log("| > resetState");
		FlxG.log("| > switchState [State:FlxState]");
		FlxG.log("| > resetGame");
		#if flash
		FlxG.log("| > fullscreen");
		#end
		FlxG.log("| > watchMouse (toggle)");
		FlxG.log("| > visualDebug (toggle)");
		FlxG.log("| > play [Sound:Dynamic] [Volume:Float = 1]");
		FlxG.log("| > playMusic [Sound:Dynamic] [Volume:Float = 1]");
		FlxG.log("| > bgColor [Color:UInt or color from FlxG]");
		FlxG.log("| > pauseSounds");
		FlxG.log("| > resumeSounds");
		FlxG.log("| > shake [Intensity:Float = 0.05] [Duration:Float = 0.5]");
		FlxG.log("| > volume [Volume:Float]");
		FlxG.log("| > create [Object:FlxObject] [X:Float = FlxG.mouse.x] [Y:Float = FlxG.mouse.y]");
		FlxG.log("| > set [Object] [Variable] [NewValue:Dynamic]");
		FlxG.log("| > close");
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
			FlxG.watch(FlxG.mouse, "x", "Mouse.x");
			FlxG.watch(FlxG.mouse, "y", "Mouse.y");
			FlxG.log("> watchMouse: Mouse position added to watch window");
		}
		else {
			FlxG.unwatch(FlxG.mouse, "x");
			FlxG.unwatch(FlxG.mouse, "y");
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
			obj.x = FlxG.mouse.x;
		else 
			obj.x = X;
			
		if (Y == -1) 
			obj.y = FlxG.mouse.y;
		else 
			obj.y = Y;
		
		FlxG.state.add(instance);
		FlxG.log("> create: New " + ClassName + " created at X = " + obj.x + " Y = " + obj.y);
	}
	
	private function set(AnyObject:Dynamic, VariableName:String, NewValue:Dynamic):Void
	{
		if (Std.string(AnyObject) == "state") 
			AnyObject = FlxG.state;
		
		if (!Reflect.isObject(AnyObject)) {
			FlxG.log("> set: " + Std.string(AnyObject) + " is not a valid Object");
			return;
		}
		
		if (Reflect.field(AnyObject, VariableName) == null) {
			FlxG.log("> set: " + Std.string(AnyObject) + " does not have a field " + VariableName);
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