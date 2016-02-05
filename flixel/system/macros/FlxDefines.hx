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
	/**
	 * Mostly internal, makes sure that flixel can be built with pure haxe
	 * (as opposed to lime-tools). Needed for API doc generation and unit tests.
	 */
	FLX_HAXE_BUILD;
	FLX_UNIT_TEST;
	/* additional rendering define */
	FLX_RENDER_TRIANGLE;
}

/**
 * These are "typedef defines" - complex #if / #elseif conditions
 * are shortened into a single define to avoid the redundancy
 * that comes with using them frequently.
 */
private enum HelperDefines
{
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
		#if (haxe_ver < "3.2")
		abort('The minimum required Haxe version for HaxeFlixel is 3.2.0. '
			+ 'Please install a newer version.', FlxMacroUtil.here());
		#end
		
		#if ((haxe_ver == "3.201") && flixel_ui)
		if (defined("cpp"))
			abort('flixel-ui is not compatible with Haxe 3.2.1 on the cpp target'
				+' due to a compiler bug (#4343). Please use a different Haxe version.',
				FlxMacroUtil.here());
		#end
		
		checkDefines();
		defineHelperDefines();
		
		if (defined("flash"))
		{
			checkSwfVersion();
		}
	}
	
	private static function checkDefines()
	{
		for (define in HelperDefines.getConstructors())
		{
			abortIfDefined(define);
		}
		
		#if (haxe_ver >= "3.2")
		var userDefinable = UserDefines.getConstructors();
		for (define in Context.getDefines().keys())
		{
			if (define.startsWith("FLX_") && userDefinable.indexOf(define) == -1)
			{
				Context.warning('"$define" is not a valid flixel define.', FlxMacroUtil.here());
			}
		}
		#end
	}
	
	private static function abortIfDefined(define:String)
	{
		if (defined(define))
		{
			abort('$define can only be defined by flixel.', FlxMacroUtil.here());
		}
	}
	
	private static function defineHelperDefines()
	{
		if (!defined(FLX_NO_MOUSE) && !defined(FLX_NO_MOUSE_ADVANCED) && (!defined("flash") || defined("flash11_2")))
		{
			define(FLX_MOUSE_ADVANCED);
		}
		
		if (!defined(FLX_NO_MOUSE) && !defined(FLX_NO_NATIVE_CURSOR) && defined("flash10_2"))
		{
			define(FLX_NATIVE_CURSOR);
		}
		
		if ((defined("openfl_next") && !defined("flash")) || defined("flash11_8"))
		{
			define(FLX_GAMEINPUT_API);
		}
		else if (!defined("openfl_next") && (defined("cpp") || defined("neko")))
		{
			define(FLX_JOYSTICK_API);
		}
		
		if (!defined(FLX_NO_SOUND_SYSTEM) && !defined(FLX_NO_SOUND_TRAY))
		{
			define(FLX_SOUND_TRAY);
		}
		
		if (!defined(FLX_NO_TOUCH) || !defined(FLX_NO_MOUSE))
		{
			define(FLX_POINTER_INPUT);
		}
		
		if (defined("cpp") || defined("neko"))
		{
			define(FLX_POST_PROCESS);
		}
	}
	
	private static function checkSwfVersion()
	{
		if (!defined("flash11"))
			abort("The minimum required Flash Player version for HaxeFlixel is 11." +
				" Please specify a newer version in your Project.xml file.", FlxMacroUtil.here());
		
		swfVersionError("Middle and right mouse button events are", "11.2", FLX_NO_MOUSE_ADVANCED);
		swfVersionError("Gamepad input is", "11.8", FLX_NO_GAMEPAD);
	}
	
	private static function swfVersionError(feature:String, version:String, define:UserDefines)
	{
		var errorMessage = '[feature] only supported in Flash Player version [version] or higher. '
			+ 'Define [define] to disable this feature or add <set name="SWF_VERSION" value="$version" /> to your Project.xml.';
		
		if (!defined("flash" + version.replace(".", "_")) && !defined(define))
		{
			abort(errorMessage
				.replace("[feature]", feature)
				.replace("[version]", version)
				.replace("[define]", define.getName()),
				FlxMacroUtil.here());
		}
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