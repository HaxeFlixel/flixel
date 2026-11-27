package flixel.system.debug.console;

import flixel.system.frontEnds.ConsoleFrontEnd;
#if FLX_DEBUG
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.debug.FlxDebugger.FlxDebuggerLayout;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;

using StringTools;

class ConsoleCommands
{
	var _window:Console;
	
	@:deprecated("_console is deprecated, use _window, instead")
	var _console(get, never):Console;
	inline function get__console():Console return _window;
	
	/**
	 * Helper variable for toggling the mouse coords in the watch window.
	 */
	var _watchingMouse:Bool = false;

	public function new(window:Console, console:ConsoleFrontEnd):Void
	{
		_window = window;
		
		console.registerFunction("help", help, "Displays the help text of a registered object or function. See \"help\".");
		console.registerFunction("close", close, "Closes the debugger overlay.");

		console.registerFunction("clearHistory", _window.history.clear, "Closes the debugger overlay.");
		console.registerFunction("clearLog", FlxG.log.clear, "Clears the command history.");

		console.registerFunction("fields", fields, "Lists the fields of a class or instance");

		console.registerFunction("listObjects", listObjects, "Lists the aliases of all registered objects.");
		console.registerFunction("listFunctions", listFunctions, "Lists the aliases of all registered functions.");

		console.registerFunction("step", step, "Steps the game forward one frame if currently paused. No effect if unpaused.");
		console.registerFunction("pause", pause, "Toggles the game between paused and unpaused.");

		console.registerFunction("clearBitmapLog", FlxG.bitmapLog.clear, "Clears the bitmapLog window.");
		console.registerFunction("viewCache", FlxG.bitmapLog.viewCache, "Adds the cache to the bitmapLog window.");

		console.registerFunction("create", (objCl, mPos, params)->create(objCl, mPos, params, console),
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
		@:access(flixel.math.FlxPoint.FlxBasePoint)
		console.registerObject("FlxPoint", FlxBasePoint);
		console.registerClass(FlxRect);

		console.registerEnum(FlxDebuggerLayout);

		console.registerObject("selection", null);
	}

	function help(?Alias:String):String
	{
		if (Alias == null || Alias.length == 0)
		{
			var output:String = "System classes and commands: ";
			for (obj in _window.registeredObjects.keys())
			{
				output += obj + ", ";
			}
			for (func in _window.registeredFunctions.keys())
			{
				output += func + "(), ";
			}
			return output + "\nTry 'help(\"command\")' for more information about a specific command.";
		}
		else
		{
			if (_window.registeredHelp.exists(Alias))
			{
				return Alias + (_window.registeredFunctions.exists(Alias) ? "()" : "") + ": " + _window.registeredHelp.get(Alias);
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

	function create<T:FlxObject>(objClass:Class<T>, mousePos:Bool = true, ?params:Array<Dynamic>, console:ConsoleFrontEnd):Void
	{
		if (params == null)
			params = [];

		var obj:FlxObject = Type.createInstance(objClass, params);

		if (obj == null)
			return;

		if (mousePos)
		{
			obj.x = FlxG.game.mouseX;
			obj.y = FlxG.game.mouseY;
		}

		FlxG.state.add(obj);

		if (params.length == 0)
			log("create: New " + objClass + " created at X = " + obj.x + " Y = " + obj.y);
		else
			log("create: New " + objClass + " created at X = " + obj.x + " Y = " + obj.y + " with params " + params);

		_window.objectStack.push(obj);

		var name = "Object_" + _window.objectStack.length;
		console.registerObject(name, obj);

		log("create: " + objClass + " registered as '" + name + "'");
	}

	function fields(Object:Dynamic):String
	{
		return 'Fields of ${Type.getClassName(Object)}:\n' + FlxG.console.handler.getFields(Object).join("\n").trim();
	}

	function listObjects():Void
	{
		log("Objects registered: \n" + FlxStringUtil.formatStringMap(_window.registeredObjects));
	}

	function listFunctions():Void
	{
		log("Functions registered: \n" + FlxStringUtil.formatStringMap(_window.registeredFunctions));
	}

	function watchMouse():Void
	{
		if (!_watchingMouse)
		{
			FlxG.watch.addMouse();
			log("watchMouse: Mouse position added to watch window");
		}
		else
		{
			FlxG.watch.removeMouse();
			log("watchMouse: Mouse position removed from watch window");
		}

		_watchingMouse = !_watchingMouse;
	}

	function pause():Void
	{
		if (FlxG.vcr.paused)
		{
			FlxG.vcr.resume();
			log("pause: Game unpaused");
		}
		else
		{
			FlxG.vcr.pause();
			log("pause: Game paused");
		}
	}

	function step():Void
	{
		if (FlxG.vcr.paused)
			FlxG.game.debugger.vcr.onStep();
	}
	
	function log(message:String)
	{
		FlxG.log.advanced([message], FlxG.log.styles.console);
	}
}
#end
