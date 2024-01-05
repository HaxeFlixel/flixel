package flixel.system.macros;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Position;
#if (flixel_addons >= "3.2.2")
import flixel.addons.system.macros.FlxAddonDefines;
#end


using StringTools;

private enum UserDefines
{
	FLX_NO_MOUSE_ADVANCED;
	FLX_NO_GAMEPAD;
	FLX_NO_NATIVE_CURSOR;
	FLX_NO_MOUSE;
	FLX_NO_TOUCH;
	FLX_NO_KEYBOARD;
	FLX_NO_SOUND_SYSTEM;
	FLX_NO_SOUND_TRAY;
	FLX_NO_FOCUS_LOST_SCREEN;
	FLX_NO_DEBUG;
	FLX_RECORD;
	/* Defined in HaxeFlixel CI tests, do not use */
	FLX_UNIT_TEST;
	/* Defined in HaxeFlixel CI tests, do not use */
	FLX_COVERAGE_TEST;
	/* Defined in HaxeFlixel CI tests, do not use */
	FLX_SWF_VERSION_TEST;
	/* additional rendering define */
	FLX_RENDER_TRIANGLE;
	/* Uses flixel 4.0 legacy collision */
	FLX_4_LEGACY_COLLISION;
	/* Simplifies FlxPoint but can increase GC frequency */
	FLX_NO_POINT_POOL;
	FLX_NO_PITCH;
	FLX_NO_SAVE;
}

/**
 * These are "typedef defines" - complex #if / #elseif conditions
 * are shortened into a single define to avoid the redundancy
 * that comes with using them frequently.
 */
private enum HelperDefines
{
	FLX_GAMEPAD;
	FLX_MOUSE;
	FLX_TOUCH;
	FLX_KEYBOARD;
	FLX_SOUND_SYSTEM;
	FLX_FOCUS_LOST_SCREEN;
	FLX_DEBUG;
	FLX_STEAMWRAP;

	FLX_MOUSE_ADVANCED;
	FLX_NATIVE_CURSOR;
	FLX_SOUND_TRAY;
	FLX_POINTER_INPUT;
	FLX_POST_PROCESS;
	FLX_JOYSTICK_API;
	FLX_GAMEINPUT_API;
	FLX_ACCELEROMETER;
	FLX_DRAW_QUADS;
	FLX_POINT_POOL;
	FLX_PITCH;
	/* Used in HaxeFlixel CI, should have no effect on personal projects */
	FLX_NO_UNIT_TEST;
	/* Used in HaxeFlixel CI, should have no effect on personal projects */
	FLX_NO_COVERAGE_TEST;
	/* Used in HaxeFlixel CI, should have no effect on personal projects */
	FLX_NO_SWF_VERSION_TEST;
	/* Used in HaxeFlixel CI, should have no effect on personal projects */
	FLX_CI;
	/* Used in HaxeFlixel CI, should have no effect on personal projects */
	FLX_NO_CI;
	FLX_SAVE;
}

class FlxDefines
{
	public static function run()
	{
		#if !display
		checkCompatibility();
		checkDefines();
		if (defined("flash"))
			checkSwfVersion();
		#end
		
		defineInversions();
		defineHelperDefines();
		
		#if (flixel_addons >= "3.2.2")
		flixel.addons.system.macros.FlxAddonDefines.run();
		#end
	}

	static function checkCompatibility()
	{
		#if (haxe < version("4.2.5"))
		abortVersion("Haxe", "4.2.5 or newer", "haxe_ver", (macro null).pos);
		#end

		#if !nme
		checkOpenFLVersions();
		#end
		
		#if (flixel_addons < "3.0.2")
		abortVersion("Flixel Addons", "3.0.2 or newer", "flixel-addons", (macro null).pos);
		#end
	}

	static function checkOpenFLVersions()
	{
		#if (lime < "8.0.2")
		abortVersion("Lime", "8.0.2 or newer", "lime", (macro null).pos);
		#end

		#if (openfl < "9.2.2")
		abortVersion("OpenFL", "9.2.2 or newer", "openfl", (macro null).pos);
		#end
	}

	static function abortVersion(dependency:String, supported:String, found:String, pos:Position)
	{
		abort('Unsupported $dependency version! Supported versions are $supported (found ${Context.definedValue(found)}).', pos);
	}

	static function checkDefines()
	{
		for (define in HelperDefines.getConstructors())
			abortIfDefined(define);

		for (define in Context.getDefines().keys())
		{
			if (isValidUserDefine(define))
			{
				Context.warning('"$define" is not a valid flixel define.', (macro null).pos);
			}
		}
	}
	
	static var userDefinable = UserDefines.getConstructors();
	static function isValidUserDefine(define:String)
	{
		return (define.startsWith("FLX_") && userDefinable.indexOf(define) == -1)
			#if (flixel_addons >= version("3.2.2")) || FlxAddonDefines.isValidUserDefine(define) #end;
	}

	static function abortIfDefined(define:String)
	{
		if (defined(define))
			abort('$define can only be defined by flixel.', (macro null).pos);
	}

	static function defineInversions()
	{
		defineInversion(FLX_NO_GAMEPAD, FLX_GAMEPAD);
		defineInversion(FLX_NO_MOUSE, FLX_MOUSE);
		defineInversion(FLX_NO_TOUCH, FLX_TOUCH);
		defineInversion(FLX_NO_KEYBOARD, FLX_KEYBOARD);
		defineInversion(FLX_NO_SOUND_SYSTEM, FLX_SOUND_SYSTEM);
		defineInversion(FLX_NO_FOCUS_LOST_SCREEN, FLX_FOCUS_LOST_SCREEN);
		defineInversion(FLX_NO_DEBUG, FLX_DEBUG);
		defineInversion(FLX_NO_POINT_POOL, FLX_POINT_POOL);
		defineInversion(FLX_UNIT_TEST, FLX_NO_UNIT_TEST);
		defineInversion(FLX_COVERAGE_TEST, FLX_NO_COVERAGE_TEST);
		defineInversion(FLX_SWF_VERSION_TEST, FLX_NO_SWF_VERSION_TEST);
	}

	static function defineHelperDefines()
	{
		if (defined(FLX_UNIT_TEST) || defined(FLX_COVERAGE_TEST) || defined(FLX_SWF_VERSION_TEST))
			define(FLX_CI);
		else
			define(FLX_NO_CI);
		
		if (!defined(FLX_NO_MOUSE) && !defined(FLX_NO_MOUSE_ADVANCED) && (!defined("flash") || defined("flash11_2")))
			define(FLX_MOUSE_ADVANCED);

		if (!defined(FLX_NO_MOUSE) && !defined(FLX_NO_NATIVE_CURSOR) && defined("flash10_2"))
			define(FLX_NATIVE_CURSOR);

		if (!defined(FLX_NO_SOUND_SYSTEM) && !defined(FLX_NO_SOUND_TRAY))
			define(FLX_SOUND_TRAY);

		#if (lime >= "8.0.0")
		if (defined(FLX_NO_SOUND_SYSTEM) || defined("flash"))
			define(FLX_NO_PITCH);
		#else
		define(FLX_NO_PITCH);
		#end

		if (!defined(FLX_NO_PITCH))
			define(FLX_PITCH);
		
		if (!defined(FLX_NO_SAVE))
			define(FLX_SAVE);
		
		if (!defined("flash") || defined("flash11_8"))
			define(FLX_GAMEINPUT_API);
		else if (!defined("openfl_next") && (defined("cpp") || defined("neko")))
			define(FLX_JOYSTICK_API);

		#if nme
		define(FLX_JOYSTICK_API);
		#end

		if (!defined(FLX_NO_TOUCH) || !defined(FLX_NO_MOUSE))
			define(FLX_POINTER_INPUT);

		#if (openfl < "4.0.0")
		if (defined("cpp") || defined("neko"))
			define(FLX_POST_PROCESS);
		#end

		if (defined("cpp") && defined("steamwrap"))
			define(FLX_STEAMWRAP);

		if (defined("mobile") || defined("js"))
			define(FLX_ACCELEROMETER);

		// #if (openfl >= "8.0.0")
		// should always be defined as of 5.5.1 and, therefore, deprecated
		define(FLX_DRAW_QUADS);
		// #end
	}

	static function defineInversion(userDefine:UserDefines, invertedDefine:HelperDefines)
	{
		if (!defined(userDefine))
			define(invertedDefine);
	}

	static function checkSwfVersion()
	{
		if (!defined("flash11"))
			abort("The minimum required Flash Player version for HaxeFlixel is 11." + " Please specify a newer version in your Project.xml file.",
				(macro null).pos);

		swfVersionError("Middle and right mouse button events are", "11.2", FLX_NO_MOUSE_ADVANCED);
		swfVersionError("Gamepad input is", "11.8", FLX_NO_GAMEPAD);
	}

	static function swfVersionError(feature:String, version:String, define:UserDefines)
	{
		var errorMessage = '$feature only supported in Flash Player version $version or higher. '
			+ 'Define ${define.getName()} to disable this feature or add <set name="SWF_VERSION" value="$version" /> to your Project.xml.';

		if (!defined("flash" + version.replace(".", "_")) && !defined(define))
			abort(errorMessage, (macro null).pos);
	}

	static inline function defined(define:Dynamic)
	{
		return Context.defined(Std.string(define));
	}

	static inline function define(define:Dynamic)
	{
		Compiler.define(Std.string(define));
	}

	static function abort(message:String, pos:Position)
	{
		Context.fatalError(message, pos);
	}
}
