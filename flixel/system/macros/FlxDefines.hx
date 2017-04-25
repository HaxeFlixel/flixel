package flixel.system.macros;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Position;
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
	FLX_UNIT_TEST;
	/* additional rendering define */
	FLX_RENDER_GL;
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
	
	FLX_MOUSE_ADVANCED;
	FLX_NATIVE_CURSOR;
	FLX_SOUND_TRAY;

	FLX_POINTER_INPUT;
	FLX_POST_PROCESS;
	FLX_JOYSTICK_API;
	FLX_GAMEINPUT_API;
}

class FlxDefines
{
	public static function run()
	{
		#if !display
		checkDependencyCompatibility();
		checkDefines();
		if (defined("flash"))
			checkSwfVersion();
		#end

		defineInversions();
		defineHelperDefines();
	}
	
	private static function checkDependencyCompatibility()
	{
		#if (haxe_ver < "3.2")
		abortMinVersion("Haxe", "3.2.0", (macro null).pos);
		#end
		
		#if ((haxe_ver == "3.201") && flixel_ui)
		if (defined("cpp"))
			abort('flixel-ui is not compatible with Haxe 3.2.1 on the cpp target'
				+' due to a compiler bug (#4343). Please use a different Haxe version.',
				(macro null).pos);
		#end
		
		#if !nme
		checkOpenFLVersions();
		#end
	}

	private static function checkOpenFLVersions()
	{
		#if (openfl < "3.5.0")
		abortMinVersion("OpenFL", "3.5.0", (macro null).pos);
		#end

		#if (lime < "2.8.1")
		abortMinVersion("Lime", "2.8.1", (macro null).pos);
		#end
	}

	private static function abortMinVersion(dependency:String, minimumRequired:String, pos:Position)
	{
		abort('The minimum required $dependency version for HaxeFlixel is $minimumRequired. '
			+ 'Please install a newer version.', pos);
	}

	private static function abortMaxVersion(lib:String, firstIncompatible:String, lastCompatible:String, pos:Position)
	{
		abort('Please run \'haxelib set ${lib.toLowerCase()} $lastCompatible\'' +
			' (Flixel is currently incompatible with $lib $firstIncompatible or newer).' , pos);
	}
	
	private static function checkDefines()
	{
		for (define in HelperDefines.getConstructors())
			abortIfDefined(define);
		
		#if (haxe_ver >= "3.2")
		var userDefinable = UserDefines.getConstructors();
		for (define in Context.getDefines().keys())
		{
			if (define.startsWith("FLX_") && userDefinable.indexOf(define) == -1)
			{
				Context.warning('"$define" is not a valid flixel define.', (macro null).pos);
			}
		}
		#end
	}
	
	private static function abortIfDefined(define:String)
	{
		if (defined(define))
			abort('$define can only be defined by flixel.', (macro null).pos);
	}

	private static function defineInversions()
	{
		defineInversion(FLX_NO_GAMEPAD, FLX_GAMEPAD);
		defineInversion(FLX_NO_MOUSE, FLX_MOUSE);
		defineInversion(FLX_NO_TOUCH, FLX_TOUCH);
		defineInversion(FLX_NO_KEYBOARD, FLX_KEYBOARD);
		defineInversion(FLX_NO_SOUND_SYSTEM, FLX_SOUND_SYSTEM);
		defineInversion(FLX_NO_FOCUS_LOST_SCREEN, FLX_FOCUS_LOST_SCREEN);
		defineInversion(FLX_NO_DEBUG, FLX_DEBUG);
	}

	private static function defineHelperDefines()
	{
		if (!defined(FLX_NO_MOUSE) && !defined(FLX_NO_MOUSE_ADVANCED) && (!defined("flash") || defined("flash11_2")))
			define(FLX_MOUSE_ADVANCED);
		
		if (!defined(FLX_NO_MOUSE) && !defined(FLX_NO_NATIVE_CURSOR) && defined("flash10_2"))
			define(FLX_NATIVE_CURSOR);
		
		if (!defined(FLX_NO_SOUND_SYSTEM) && !defined(FLX_NO_SOUND_TRAY))
			define(FLX_SOUND_TRAY);
		
		#if (openfl >= "4.0.0")
		if (defined("flash11_8") || (defined("cpp") || defined("neko")) || defined("js"))
			define(FLX_GAMEINPUT_API);
		
		if (!defined("flash"))
			define(FLX_RENDER_GL);
		#else
		if ((defined("openfl_next") && !defined("flash")) || defined("flash11_8"))
			define(FLX_GAMEINPUT_API);
		else if (!defined("openfl_next") && (defined("cpp") || defined("neko")))
			define(FLX_JOYSTICK_API);
		#end
		
		if (!defined(FLX_NO_TOUCH) || !defined(FLX_NO_MOUSE))
			define(FLX_POINTER_INPUT);
		
		#if (openfl < "4.0.0")
		if (defined("cpp") || defined("neko"))
			define(FLX_POST_PROCESS);
		#end
	}
	
	private static function defineInversion(userDefine:UserDefines, invertedDefine:HelperDefines)
	{
		if (!defined(userDefine))
			define(invertedDefine);
	}
	
	private static function checkSwfVersion()
	{
		if (!defined("flash11"))
			abort("The minimum required Flash Player version for HaxeFlixel is 11." +
				" Please specify a newer version in your Project.xml file.", (macro null).pos);
		
		swfVersionError("Middle and right mouse button events are", "11.2", FLX_NO_MOUSE_ADVANCED);
		swfVersionError("Gamepad input is", "11.8", FLX_NO_GAMEPAD);
	}
	
	private static function swfVersionError(feature:String, version:String, define:UserDefines)
	{
		var errorMessage = '$feature only supported in Flash Player version $version or higher. '
			+ 'Define ${define.getName()} to disable this feature or add <set name="SWF_VERSION" value="$version" /> to your Project.xml.';
		
		if (!defined("flash" + version.replace(".", "_")) && !defined(define))
			abort(errorMessage, (macro null).pos);
	}
	
	private static inline function defined(define:Dynamic)
	{
		return Context.defined(Std.string(define));
	}
	
	private static inline function define(define:Dynamic)
	{
		Compiler.define(Std.string(define));
	}
	
	private static function abort(message:String, pos:Position)
	{
		Context.fatalError(message, pos);
	}
}
#end