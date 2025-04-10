package flixel.system.macros;

import haxe.io.Path;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Position;
using StringTools;
#if (flixel_addons >= "3.2.2")
import flixel.addons.system.macros.FlxAddonDefines;
#end



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
	/* Removes FlxObject.health */
	FLX_NO_HEALTH;
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
	/** Adds trackers to FlxPool instances, only available on debug */
	FLX_TRACK_POOLS;
	/** Adds `creationInfo` to FlxGraphic instances, automatically defined with FLX_DEBUG */
	FLX_TRACK_GRAPHICS;
	/**
	 * Loads from the specified relative or absolute directory. Unlike other boolean flags,
	 * this flag should contain a string value.
	 * 
	 * **Note:** When using assets entirely from outside the build directory, it is wise to disable
	 * any `</asset>` tags in your project.xml, to reduce your total memory
	 */
	FLX_CUSTOM_ASSETS_DIRECTORY;
	/**
	 * Allows you to use sound paths with no extension, and the default sound type for that
	 * target will be used. If enabled it will use ogg on all targets except flash, which uses mp3.
	 * If this flag is set to any string, that is used for the file extension
	 */
	FLX_DEFAULT_SOUND_EXT;
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
	FLX_HEALTH;
	FLX_NO_TRACK_POOLS;
	FLX_NO_TRACK_GRAPHICS;
	FLX_OPENGL_AVAILABLE;
	/** Defined to `1`(or `true`) if `FLX_CUSTOM_ASSETS_DIRECTORY` is not defined */
	FLX_STANDARD_ASSETS_DIRECTORY;
	/** The normalized, absolute path of `FLX_CUSTOM_ASSETS_DIRECTORY`, used internally */
	FLX_CUSTOM_ASSETS_DIRECTORY_ABS;
	FLX_NO_DEFAULT_SOUND_EXT;
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
		#if (flixel_ui >= "2.6.0")
		flixel.addons.ui.system.macros.FlxUIDefines.run();
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
		
		#if (flixel_addons < version("3.3.0"))
		abortVersion("Flixel Addons", "3.3.0 or newer", "flixel-addons", (macro null).pos);
		#end
		#if (flixel_ui < version("2.6.2"))
		abortVersion("Flixel UI", "2.6.2 or newer", "flixel_ui", (macro null).pos);
		#end
	}

	static function checkOpenFLVersions()
	{
		#if (lime < version("8.0.2"))
		abortVersion("Lime", "8.0.2 or newer", "lime", (macro null).pos);
		#end

		#if (openfl < version("9.2.2"))
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
		defineInversion(FLX_NO_HEALTH, FLX_HEALTH);
		defineInversion(FLX_TRACK_POOLS, FLX_NO_TRACK_POOLS);
		defineInversion(FLX_DEFAULT_SOUND_EXT, FLX_NO_DEFAULT_SOUND_EXT);
		// defineInversion(FLX_TRACK_GRAPHICS, FLX_NO_TRACK_GRAPHICS); // special case
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

		if (defined(FLX_NO_SOUND_SYSTEM) || defined("flash"))
			define(FLX_NO_PITCH);

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

		if (defined("cpp") && defined("steamwrap"))
			define(FLX_STEAMWRAP);

		if (defined("mobile") || defined("js"))
			define(FLX_ACCELEROMETER);

		// #if (openfl >= "8.0.0")
		// should always be defined as of 5.5.1 and, therefore, deprecated
		define(FLX_DRAW_QUADS);
		// #end
		
		if (defined(FLX_TRACK_POOLS) && !defined("debug"))
			abort("Can only define FLX_TRACK_POOLS on debug mode", (macro null).pos);
		
		if (defined(FLX_DEBUG))
			define(FLX_TRACK_GRAPHICS);

		#if (lime_opengl || lime_opengles || lime_webgl)
		// FlxG.stage.window.context.attributes.hardware is not always defined during unit tests
		if (defined(FLX_NO_UNIT_TEST))
			define(FLX_OPENGL_AVAILABLE);
		#end
		
		defineInversion(FLX_TRACK_GRAPHICS, FLX_NO_TRACK_GRAPHICS);
		
		if (defined(FLX_CUSTOM_ASSETS_DIRECTORY))
		{
			if (!defined("sys"))
			{
				abort('FLX_CUSTOM_ASSETS_DIRECTORY is only available on sys targets', (macro null).pos);
			}
			else
			{
				// Todo: check sys targets
				final rawDirectory = Path.normalize(definedValue(FLX_CUSTOM_ASSETS_DIRECTORY));
				final directory = Path.normalize(rawDirectory);
				final absPath = sys.FileSystem.absolutePath(directory);
				if (!sys.FileSystem.isDirectory(directory) || directory == "1")
				{
					abort('FLX_CUSTOM_ASSETS_DIRECTORY must be a path to a directory, got "$rawDirectory"'
						+ '\nabsolute path: $absPath', (macro null).pos);
				}
				define(FLX_CUSTOM_ASSETS_DIRECTORY_ABS, absPath);
			}
		}
		else // define boolean inversion
			define(FLX_STANDARD_ASSETS_DIRECTORY);
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

	static inline function definedValue(define:Dynamic):String
	{
		return Context.definedValue(Std.string(define));
	}
	
	static inline function defined(define:Dynamic)
	{
		return Context.defined(Std.string(define));
	}

	static inline function define(define:Dynamic, ?value:String)
	{
		Compiler.define(Std.string(define), value);
	}

	static function abort(message:String, pos:Position)
	{
		Context.fatalError(message, pos);
	}
}
