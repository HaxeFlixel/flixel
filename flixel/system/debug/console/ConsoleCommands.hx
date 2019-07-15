package flixel.system.debug.console;

#if FLX_DEBUG
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxStringUtil;
import flixel.system.debug.FlxDebugger.FlxDebuggerLayout;

using StringTools;

class ConsoleCommands
{
	var _console:Console;

	/**
	 * Helper variable for toggling the mouse coords in the watch window.
	 */
	var _watchingMouse:Bool = false;

	public function new(console:Console):Void
	{
		_console = console;

		console.registerFunction("help", help, "Displays the help text of a registered object or function. See \"help\".");
		console.registerFunction("close", close, "Closes the debugger overlay.");

		console.registerFunction("clearHistory", _console.history.clear, "Closes the debugger overlay.");
		console.registerFunction("clearLog", FlxG.log.clear, "Clears the command history.");

		console.registerFunction("fields", fields, "Lists the fields of a class or instance");

		console.registerFunction("listObjects", listObjects, "Lists the aliases of all registered objects.");
		console.registerFunction("listFunctions", listFunctions, "Lists the aliases of all registered functions.");

		console.registerFunction("step", step, "Steps the game forward one frame if currently paused. No effect if unpaused.");
		console.registerFunction("pause", pause, "Toggles the game between paused and unpaused.");

		console.registerFunction("clearBitmapLog", FlxG.bitmapLog.clear, "Clears the bitmapLog window.");
		console.registerFunction("viewCache", FlxG.bitmapLog.viewCache, "Adds the cache to the bitmapLog window.");

		console.registerFunction("create", create,
			"Creates a new FlxObject and registers it - by default at the mouse position. \"create(ObjClass:Class<T>, PlaceAtMouse:Bool, ExtraParams:Array<Dynamic>)\" Ex: \"create(FlxSprite, false, [100, 100])\"");

		console.registerFunction("watch", FlxG.watch.add, "Adds the specified field of an object to the watch window.");
		console.registerFunction("watchExpression", FlxG.watch.addExpression,
			"Adds the specified expression to the watch window. Be sure any objects, functions, and classes used are registered!");
		console.registerFunction("watchMouse", watchMouse, "Adds the mouse coordinates to the watch window.");
		console.registerFunction("track", FlxG.debugger.track, "Adds a tracker window for the specified object or class.");

		// Default classes to include
		console.registerClass(Math);
		console.registerClass(Reflect);
		console.registerClass(Std);
		console.registerClass(StringTools);
		#if sys
		console.registerClass(Sys);
		#end
		console.registerClass(Type);

		console.registerClass(FlxG);
		console.registerClass(FlxObject);
		console.registerClass(FlxSprite);
		console.registerClass(FlxMath);
		console.registerClass(FlxTween);
		console.registerClass(FlxCamera);
		console.registerClass(FlxPoint);
		console.registerClass(FlxRect);

		console.registerEnum(FlxDebuggerLayout);

		console.registerObject("selection", null);
	}

	function help(?Alias:String):String
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

	inline function close():Void
	{
		FlxG.debugger.visible = false;
	}

	function create<T:FlxObject>(ObjClass:Class<T>, MousePos:Bool = true, ?Params:Array<Dynamic>):Void
	{
		if (Params == null)
			Params = [];

		var obj:FlxObject = Type.createInstance(ObjClass, Params);

		if (obj == null)
			return;

		if (MousePos)
		{
			obj.x = FlxG.game.mouseX;
			obj.y = FlxG.game.mouseY;
		}

		FlxG.state.add(obj);

		if (Params.length == 0)
			ConsoleUtil.log("create: New " + ObjClass + " created at X = " + obj.x + " Y = " + obj.y);
		else
			ConsoleUtil.log("create: New " + ObjClass + " created at X = " + obj.x + " Y = " + obj.y + " with params " + Params);

		_console.objectStack.push(obj);

		var name = "Object_" + _console.objectStack.length;
		_console.registerObject(name, obj);

		ConsoleUtil.log("create: " + ObjClass + " registered as '" + name + "'");
	}

	function fields(Object:Dynamic):String
	{
		return 'Fields of ${Type.getClassName(Object)}:\n' + ConsoleUtil.getFields(Object).join("\n").trim();
	}

	function listObjects():Void
	{
		ConsoleUtil.log("Objects registered: \n" + FlxStringUtil.formatStringMap(_console.registeredObjects));
	}

	function listFunctions():Void
	{
		ConsoleUtil.log("Functions registered: \n" + FlxStringUtil.formatStringMap(_console.registeredFunctions));
	}

	function watchMouse():Void
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

	function pause():Void
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

	function step():Void
	{
		if (FlxG.vcr.paused)
			FlxG.game.debugger.vcr.onStep();
	}
}
#end
