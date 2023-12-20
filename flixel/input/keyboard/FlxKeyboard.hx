package flixel.input.keyboard;

#if FLX_KEYBOARD
import openfl.events.KeyboardEvent;
import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.system.replay.CodeValuePair;

/**
 * Keeps track of what keys are pressed and how with handy Bools or strings.
 * Normally accessed via `FlxG.keys`. Example: `FlxG.keys.justPressed.A`
 */
class FlxKeyboard extends FlxKeyManager<FlxKey, FlxKeyList>
{
	#if !web
	/**
	 * Function and numpad keycodes on native targets are incorrect,
	 * this workaround fixes that. Thanks @HaxePunk!
	 * @see https://github.com/openfl/openfl-native/issues/193
	 */
	var _nativeCorrection:Map<String, Int>;
	#end

	public function new()
	{
		super(FlxKeyList.new);

		#if html5
		preventDefaultKeys = [FlxKey.UP, FlxKey.DOWN, FlxKey.LEFT, FlxKey.RIGHT, FlxKey.SPACE, FlxKey.TAB];
		#end

		for (code in FlxKey.fromStringMap)
		{
			if (code != FlxKey.ANY && code != FlxKey.NONE)
			{
				var input = new FlxKeyInput(code);
				_keyListArray.push(input);
				_keyListMap.set(code, input);
			}
		}

		#if !web
		_nativeCorrection = new Map<String, Int>();

		_nativeCorrection.set("0_64", FlxKey.INSERT);
		_nativeCorrection.set("0_65", FlxKey.END);
		_nativeCorrection.set("0_67", FlxKey.PAGEDOWN);
		_nativeCorrection.set("0_69", FlxKey.NONE);
		_nativeCorrection.set("0_73", FlxKey.PAGEUP);
		_nativeCorrection.set("0_266", FlxKey.DELETE);
		_nativeCorrection.set("123_222", FlxKey.LBRACKET);
		_nativeCorrection.set("125_187", FlxKey.RBRACKET);
		_nativeCorrection.set("126_233", FlxKey.GRAVEACCENT);
		#if mac _nativeCorrection.set("0_43", FlxKey.PLUS); #end

		_nativeCorrection.set("0_80", FlxKey.F1);
		_nativeCorrection.set("0_81", FlxKey.F2);
		_nativeCorrection.set("0_82", FlxKey.F3);
		_nativeCorrection.set("0_83", FlxKey.F4);
		_nativeCorrection.set("0_84", FlxKey.F5);
		_nativeCorrection.set("0_85", FlxKey.F6);
		_nativeCorrection.set("0_86", FlxKey.F7);
		_nativeCorrection.set("0_87", FlxKey.F8);
		_nativeCorrection.set("0_88", FlxKey.F9);
		_nativeCorrection.set("0_89", FlxKey.F10);
		_nativeCorrection.set("0_90", FlxKey.F11);

		_nativeCorrection.set("48_224", FlxKey.ZERO);
		_nativeCorrection.set("49_38", FlxKey.ONE);
		_nativeCorrection.set("50_233", FlxKey.TWO);
		_nativeCorrection.set("51_34", FlxKey.THREE);
		_nativeCorrection.set("52_222", FlxKey.FOUR);
		_nativeCorrection.set("53_40", FlxKey.FIVE);
		_nativeCorrection.set("54_189", FlxKey.SIX);
		_nativeCorrection.set("55_232", FlxKey.SEVEN);
		_nativeCorrection.set("56_95", FlxKey.EIGHT);
		_nativeCorrection.set("57_231", FlxKey.NINE);

		_nativeCorrection.set("48_64", FlxKey.NUMPADZERO);
		_nativeCorrection.set("49_65", FlxKey.NUMPADONE);
		_nativeCorrection.set("50_66", FlxKey.NUMPADTWO);
		_nativeCorrection.set("51_67", FlxKey.NUMPADTHREE);
		_nativeCorrection.set("52_68", FlxKey.NUMPADFOUR);
		_nativeCorrection.set("53_69", FlxKey.NUMPADFIVE);
		_nativeCorrection.set("54_70", FlxKey.NUMPADSIX);
		_nativeCorrection.set("55_71", FlxKey.NUMPADSEVEN);
		_nativeCorrection.set("56_72", FlxKey.NUMPADEIGHT);
		_nativeCorrection.set("57_73", FlxKey.NUMPADNINE);

		_nativeCorrection.set("43_75", FlxKey.NUMPADPLUS);
		_nativeCorrection.set("45_77", FlxKey.NUMPADMINUS);
		_nativeCorrection.set("47_79", FlxKey.SLASH);
		_nativeCorrection.set("46_78", FlxKey.NUMPADPERIOD);
		_nativeCorrection.set("42_74", FlxKey.NUMPADMULTIPLY);
		#end
	}

	override function onKeyUp(event:KeyboardEvent):Void
	{
		super.onKeyUp(event);

		// Debugger toggle
		#if FLX_DEBUG
		if (FlxG.game.debugger != null && inKeyArray(FlxG.debugger.toggleKeys, event))
		{
			FlxG.debugger.visible = !FlxG.debugger.visible;
		}
		#end
	}

	override function onKeyDown(event:KeyboardEvent):Void
	{
		super.onKeyDown(event);

		// Attempted to cancel the replay?
		#if FLX_RECORD
		if (FlxG.game.replaying && !inKeyArray(FlxG.debugger.toggleKeys, event) && inKeyArray(FlxG.vcr.cancelKeys, event))
		{
			FlxG.vcr.cancelReplay();
		}
		#end
	}

	override function resolveKeyCode(e:KeyboardEvent):Int
	{
		#if web
		return e.keyCode;
		#else
		var code = _nativeCorrection.get(e.charCode + "_" + e.keyCode);
		return (code == null) ? e.keyCode : code;
		#end
	}

	/**
	 * If any keys are not "released",
	 * this function will return an array indicating
	 * which keys are pressed and what state they are in.
	 *
	 * @return	An array of key state data. Null if there is no data.
	 */
	@:allow(flixel.system.replay.FlxReplay)
	function record():Array<CodeValuePair>
	{
		var data:Array<CodeValuePair> = null;

		for (key in _keyListArray)
		{
			if (key == null || key.released)
			{
				continue;
			}

			if (data == null)
			{
				data = new Array<CodeValuePair>();
			}

			data.push(new CodeValuePair(key.ID, key.current));
		}

		return data;
	}

	/**
	 * Part of the keystroke recording system.
	 * Takes data about key presses and sets it into array.
	 *
	 * @param	Record	Array of data about key states.
	 */
	@:allow(flixel.system.replay.FlxReplay)
	function playback(Record:Array<CodeValuePair>):Void
	{
		var i:Int = 0;
		var l:Int = Record.length;

		while (i < l)
		{
			var o = Record[i++];
			var o2 = getKey(o.code);
			o2.current = o.value;
		}
	}
}

typedef FlxKeyInput = FlxInput<FlxKey>;
#end
