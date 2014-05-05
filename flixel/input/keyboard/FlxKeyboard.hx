package flixel.input.keyboard;

#if !FLX_NO_KEYBOARD
import flash.events.KeyboardEvent;
import flash.Lib;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.interfaces.IFlxInput;
import flixel.system.replay.CodeValuePair;
import flixel.util.FlxArrayUtil;

/**
 * Keeps track of what keys are pressed and how with handy Bools or strings.
 */
@:allow(flixel.system.replay.FlxReplay)
@:allow(flixel.input.keyboard.FlxKeyList)
class FlxKeyboard implements IFlxInput
{
	/**
	 * Total amount of keys.
	 */
	private static inline var TOTAL:Int = 256;
	
	/**
	 * Whether or not keyboard input is currently enabled.
	 */
	public var enabled:Bool = true;
	
	/**
	 * Helper class to check if a keys is pressed.
	 */
	public var pressed:FlxKeyList;
	/**
	 * Helper class to check if a keys was just pressed.
	 */
	public var justPressed:FlxKeyList;
	/**
	 * Helper class to check if a keys was just released.
	 */
	public var justReleased:FlxKeyList;
	
	/**
	 * An array of FlxKey objects.
	 */
	@:allow(flixel.input.android.FlxAndroidKeyList.get_ANY)
	private var _keyList:Array<FlxKey>;
	/**
	 * A map for key lookup.
	 */
	private var _keyLookup:Map<String, Int>;
	/**
	 * Function and numpad keycodes on native targets are incorrect, 
	 * this workaround fixes that. Thanks @HaxePunk!
	 * @see https://github.com/openfl/openfl-native/issues/193
	 */
	#if !(flash || js)
	private var _nativeCorrection:Map<String, Int>;
	#end
	
	/**
	 * Check to see if at least one key from an array of keys is pressed. See FlxG.keys for the key names, pass them in as Strings.
	 * Example: FlxG.keys.anyPressed(["UP", "W", "SPACE"]) - having them in an array is handy for configurable keys!
	 * 
	 * @param	KeyArray 	An array of keys as Strings
	 * @return	Whether at least one of the keys passed in is pressed.
	 */
	public inline function anyPressed(KeyArray:Array<String>):Bool
	{ 
		return checkKeyStatus(KeyArray, FlxKey.PRESSED);
	}
	
	/**
	 * Check to see if at least one key from an array of keys was just pressed. See FlxG.keys for the key names, pass them in as Strings.
	 * Example: FlxG.keys.anyJustPressed(["UP", "W", "SPACE"]) - having them in an array is handy for configurable keys!
	 * 
	 * @param	KeyArray 	An array of keys as Strings
	 * @return	Whether at least one of the keys passed was just pressed.
	 */
	public inline function anyJustPressed(KeyArray:Array<String>):Bool
	{ 
		return checkKeyStatus(KeyArray, FlxKey.JUST_PRESSED);
	}
	
	/**
	 * Check to see if at least one key from an array of keys was just released. See FlxG.keys for the key names, pass them in as Strings.
	 * Example: FlxG.keys.anyJustReleased(["UP", "W", "SPACE"]) - having them in an array is handy for configurable keys!
	 * 
	 * @param	KeyArray 	An array of keys as Strings
	 * @return	Whether at least one of the keys passed was just released.
	 */
	public inline function anyJustReleased(KeyArray:Array<String>):Bool
	{ 
		return checkKeyStatus(KeyArray, FlxKey.JUST_RELEASED);
	}
	
		/**
	 * Get the name of the first key which is currently pressed.
	 * 
	 * @return	The name of the key or "" if none could be found.
	 */
	public function firstPressed():String
	{
		for (key in _keyList)
		{
			if (key != null && key.current == FlxKey.PRESSED)
			{
				return key.name;
			}
		}
		return "";
	}
	
	/**
	 * Get the name of the first key which has just been pressed.
	 * 
	 * @return	The name of the key or "" if none could be found.
	 */
	public function firstJustPressed():String
	{
		for (key in _keyList)
		{
			if (key != null && key.current == FlxKey.JUST_PRESSED)
			{
				return key.name;
			}
		}
		return "";
	}
	
	/**
	 * Get the name of the first key which has just been released.
	 * 
	 * @return	The name of the key or "" if none could be found.
	 */
	public function firstJustReleased():String
	{
		for (key in _keyList)
		{
			if (key != null && key.current == FlxKey.JUST_RELEASED)
			{
				return key.name;
			}
		}
		return "";
	}
	
	/**
	 * Check the status of a single of key
	 * 
	 * @param	KeyCode		Index into _keyList array.
	 * @param	Status		The key state to check for
	 * @return	Whether the provided key has the specified status
	 */
	public function checkStatus(KeyCode:Int, Status:Int):Bool
	{
		var k:FlxKey = _keyList[KeyCode];
		if (k != null)
		{
			if (k.current == Status)
			{
				return true;
			}
			else if (Status == FlxKey.PRESSED && k.current == FlxKey.JUST_PRESSED)
			{
				return true;
			}
			else if (Status == FlxKey.RELEASED && k.current == FlxKey.JUST_RELEASED)
			{
				return true;
			}
		}
		#if !FLX_NO_DEBUG
		else
		{
			FlxG.log.error("Invalid Key: `" + KeyCode + "`.");
		}
		#end
		
		return false;
	}
	
	/**
	 * Look up the key code for any given string name of the key or button.
	 * 
	 * @param	KeyName		The String name of the key.
	 * @return	The key code for that key.
	 */
	public inline function getKeyCode(KeyName:String):Int
	{
		return _keyLookup.get(KeyName);
	}

	/**
	 * Get an Array of FlxKey that are in a pressed state
	 * 
	 * @return	Array<FlxKey> of keys that are currently pressed.
	 */
	public function getIsDown():Array<FlxKey>
	{
		var keysDown:Array<FlxKey> = new Array<FlxKey>();
		
		for (key in _keyList)
		{
			if (key != null && key.current > FlxKey.RELEASED)
			{
				keysDown.push(key);
			}
		}
		return keysDown;
	}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_keyList = null;
		_keyLookup = null;
	}
	
	/**
	 * Resets all the keys.
	 */
	public function reset():Void
	{
		for (key in _keyList)
		{
			if (key != null)
			{
				key.current = FlxKey.RELEASED;
				key.last = FlxKey.RELEASED;
			}
		}
	}
	
	@:allow(flixel.FlxG)
	private function new()
	{
		_keyLookup = new Map<String, Int>();
		
		_keyList = new Array<FlxKey>();
		FlxArrayUtil.setLength(_keyList, TOTAL);
		
		var i:Int;
		
		// LETTERS
		i = 65;
		
		while (i <= 90)
		{
			addKey(String.fromCharCode(i), i);
			i++;
		}
		
		// NUMBERS
		i = 48;
		addKey("ZERO", i++);
		addKey("ONE", i++);
		addKey("TWO", i++);
		addKey("THREE", i++);
		addKey("FOUR", i++);
		addKey("FIVE", i++);
		addKey("SIX", i++);
		addKey("SEVEN", i++);
		addKey("EIGHT", i++);
		addKey("NINE", i++);
		i = 96;
		addKey("NUMPADZERO", i++);
		addKey("NUMPADONE", i++);
		addKey("NUMPADTWO", i++);
		addKey("NUMPADTHREE", i++);
		addKey("NUMPADFOUR", i++);
		addKey("NUMPADFIVE", i++);
		addKey("NUMPADSIX", i++);
		addKey("NUMPADSEVEN",i++);
		addKey("NUMPADEIGHT", i++);
		addKey("NUMPADNINE", i++);
		
		addKey("PAGEUP", 33);
		addKey("PAGEDOWN", 34);
		addKey("HOME", 36);
		addKey("END", 35);
		addKey("INSERT", 45);
		
		// FUNCTION KEYS
		i = 1;
		while (i <= 12)
		{
			addKey("F" + i, 111 + i);
			i++;
		}
		
		// SPECIAL KEYS + PUNCTUATION
		addKey("ESCAPE", 27);
		addKey("MINUS", 189);
		addKey("PLUS", 187);
		addKey("DELETE", 46);
		addKey("BACKSPACE", 8);
		addKey("LBRACKET", 219);
		addKey("RBRACKET", 221);
		addKey("BACKSLASH", 220);
		addKey("CAPSLOCK", 20);
		addKey("SEMICOLON", 186);
		addKey("QUOTE", 222);
		addKey("ENTER", 13);
		addKey("SHIFT", 16);
		addKey("COMMA", 188);
		addKey("PERIOD",190);
		addKey("SLASH", 191);
		addKey("NUMPADSLASH", 191);
		addKey("GRAVEACCENT", 192);
		addKey("CONTROL", 17);
		addKey("ALT", 18);
		addKey("SPACE", 32);
		addKey("UP", 38);
		addKey("DOWN", 40);
		addKey("LEFT", 37);
		addKey("RIGHT", 39);
		addKey("TAB", 9);
		addKey("PRINTSCREEN", 301);
		
		addKey("NUMPADMULTIPLY", 106);
		addKey("NUMPADMINUS", 109);
		addKey("NUMPADPLUS", 107);
		addKey("NUMPADPERIOD", 110);
		
		#if !(flash || js)
		_nativeCorrection = new Map<String, Int>();
		
		_nativeCorrection.set("0_64", FlxKey.INSERT);
		_nativeCorrection.set("0_65", FlxKey.END);
		_nativeCorrection.set("0_67", FlxKey.PAGEDOWN);
		_nativeCorrection.set("0_69", -1);
		_nativeCorrection.set("0_73", FlxKey.PAGEUP);
		_nativeCorrection.set("0_266", FlxKey.DELETE);
		_nativeCorrection.set("123_222", FlxKey.LBRACKET);
		_nativeCorrection.set("125_187", FlxKey.RBRACKET);
		_nativeCorrection.set("126_233", FlxKey.GRAVEACCENT);
		
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
		_nativeCorrection.set("47_79", FlxKey.NUMPADSLASH);
		_nativeCorrection.set("46_78", FlxKey.NUMPADPERIOD);
		_nativeCorrection.set("42_74", FlxKey.NUMPADMULTIPLY);
		#end
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		pressed = new FlxKeyList(FlxKey.PRESSED);
		justPressed = new FlxKeyList(FlxKey.JUST_PRESSED);
		justReleased = new FlxKeyList(FlxKey.JUST_RELEASED);
	}
	
	/**
	 * An internal helper function used to build the key array.
	 * 
	 * @param	KeyName		String name of the key (e.g. "LEFT" or "A")
	 * @param	KeyCode		The numeric Flash code for this key.
	 */
	private function addKey(KeyName:String, KeyCode:Int):Void
	{
		_keyLookup.set(KeyName, KeyCode);
		_keyList[KeyCode] = new FlxKey(KeyName);
	}
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	private function update():Void
	{
		for (key in _keyList)
		{
			if (key == null) 
			{
				continue;
			}
			
			if (key.last == FlxKey.JUST_RELEASED && key.current == FlxKey.JUST_RELEASED) 
			{
				key.current = FlxKey.RELEASED;
			}
			else if (key.last == FlxKey.JUST_PRESSED && key.current == FlxKey.JUST_PRESSED) 
			{
				key.current = FlxKey.PRESSED;
			}
			
			key.last = key.current;
		}
	}
	
	/**
	 * Helper function to check the status of an array of keys
	 * 
	 * @param	KeyArray	An array of keys as Strings
	 * @param	Status		The key state to check for
	 * @return	Whether at least one of the keys has the specified status
	 */
	private function checkKeyStatus(KeyArray:Array<String>, Status:Int):Bool
	{
		if (KeyArray == null)
		{
			return false;
		}
		
		for (code in KeyArray)
		{
			var key:FlxKey;
			
			// Also make lowercase keys work, like "space" or "sPaCe"
			code = code.toUpperCase();
			key = _keyList[_keyLookup.get(code)];
			
			if (key != null)
			{
				if (key.current == Status)
				{
					return true;
				}
				else if ((Status == FlxKey.PRESSED) && (key.current == FlxKey.JUST_PRESSED))
				{
					return true;
				}
				else if ((Status == FlxKey.RELEASED) && (key.current == FlxKey.JUST_RELEASED))
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	/**
	 * Event handler so FlxGame can toggle keys.
	 */
	private function onKeyUp(FlashEvent:KeyboardEvent):Void
	{
		var c:Int = resolveKeyCode(FlashEvent);
		
		// Debugger toggle
		#if !FLX_NO_DEBUG
		if (FlxG.game.debugger != null && inKeyArray(FlxG.debugger.toggleKeys, c))
		{
			FlxG.debugger.visible = !FlxG.debugger.visible;
		}
		#end
		
		// Everything from on here is only updated if input is enabled
		if (!enabled) 
		{
			return;
		}
		
		#if !FLX_NO_SOUND_SYSTEM
		// Sound tray controls
		// Mute key
		if (inKeyArray(FlxG.sound.muteKeys, c))
		{
			FlxG.sound.muted = !FlxG.sound.muted;
			
			if (FlxG.sound.volumeHandler != null)
			{
				FlxG.sound.volumeHandler(FlxG.sound.muted ? 0 : FlxG.sound.volume);
			}
			
			#if !FLX_NO_SOUND_TRAY
			if (FlxG.game.soundTray != null && FlxG.sound.soundTrayEnabled)
			{
				FlxG.game.soundTray.show();
			}
			#end
		}
		// Volume down
		else if (inKeyArray(FlxG.sound.volumeDownKeys, c))
		{
			FlxG.sound.muted = false;
			FlxG.sound.volume -= 0.1;
			
			#if !FLX_NO_SOUND_TRAY
			if (FlxG.game.soundTray != null && FlxG.sound.soundTrayEnabled)
			{
				FlxG.game.soundTray.show();
			}
			#end
		}
		// Volume up
		else if (inKeyArray(FlxG.sound.volumeUpKeys, c)) 
		{
			FlxG.sound.muted = false;
			FlxG.sound.volume += 0.1;
			
			#if !FLX_NO_SOUND_TRAY
			if (FlxG.game.soundTray != null && FlxG.sound.soundTrayEnabled)
			{
				FlxG.game.soundTray.show();
			}
			#end
		}
		#end
		
		updateKeyStates(c, false);
	}
	
	/**
	 * Internal event handler for input and focus.
	 */
	private function onKeyDown(FlashEvent:KeyboardEvent):Void
	{
		var c:Int = resolveKeyCode(FlashEvent);
		
		// Attempted to cancel the replay?
		#if FLX_RECORD
		if (FlxG.game.replaying && !inKeyArray(FlxG.debugger.toggleKeys, c) && inKeyArray(FlxG.vcr.cancelKeys, c))
		{
			if (FlxG.vcr.replayCallback != null)
			{
				FlxG.vcr.replayCallback();
				FlxG.vcr.replayCallback = null;
			}
			else
			{
				FlxG.vcr.stopReplay();
			}	
		}
		#end
		
		if (enabled) 
		{
			updateKeyStates(c, true);
		}
	}
	
	/**
	 * A Helper function to check whether an array of keycodes contains 
	 * a certain key safely (returns false if the array is null).
	 */
	private function inKeyArray(KeyArray:Array<String>, KeyCode:Int):Bool
	{
		if (KeyArray == null)
		{
			return false;
		}
		else
		{
			for (keyString in KeyArray)
			{
				if (keyString == "ANY" || getKeyCode(keyString) == KeyCode)
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	private inline function resolveKeyCode(e:KeyboardEvent):Int
	{
		#if (flash || js)
		return e.keyCode;
		#else
		var code = _nativeCorrection.get(e.charCode + "_" + e.keyCode);
		return (code == null) ? e.keyCode : code;
		#end
	}
	
	/**
	 * A helper function to update the key states based on a keycode provided.
	 */
	private inline function updateKeyStates(KeyCode:Int, Down:Bool):Void
	{
		var obj:FlxKey = _keyList[KeyCode];
		
		if (obj != null) 
		{
			if (obj.current > FlxKey.RELEASED) 
			{
				if (Down)
				{
					obj.current = FlxKey.PRESSED;
				}
				else
				{
					obj.current = FlxKey.JUST_RELEASED;
				}
			}
			else 
			{
				if (Down)
				{
					obj.current = FlxKey.JUST_PRESSED;
				}
				else
				{
					obj.current = FlxKey.RELEASED;
				}
			}
		}
	}
	
	private inline function onFocus():Void {}

	private inline function onFocusLost():Void
	{
		reset();
	}
	
	/** Replay functions **/
	
	/**
	 * If any keys are not "released" (0),
	 * this function will return an array indicating
	 * which keys are pressed and what state they are in.
	 * 
	 * @return	An array of key state data.  Null if there is no data.
	 */
	private function record():Array<CodeValuePair>
	{
		var data:Array<CodeValuePair> = null;
		var i:Int = 0;
		
		while (i < TOTAL)
		{
			var key:FlxKey = _keyList[i++];
			
			if (key == null || key.current == FlxKey.RELEASED)
			{
				continue;
			}
			
			if (data == null)
			{
				data = new Array<CodeValuePair>();
			}
			
			data.push(new CodeValuePair(i - 1, key.current));
		}
		return data;
	}
	
	/**
	 * Part of the keystroke recording system.
	 * Takes data about key presses and sets it into array.
	 * 
	 * @param	Record	Array of data about key states.
	 */
	private function playback(Record:Array<CodeValuePair>):Void
	{
		var i:Int = 0;
		var l:Int = Record.length;
		var o:CodeValuePair;
		var o2:FlxKey;
		
		while (i < l)
		{
			o = Record[i++];
			o2 = _keyList[o.code];
			o2.current = o.value;
		}
	}
}
#end