package flixel.input.keyboard;
import flixel.math.FlxMath;

#if !FLX_NO_KEYBOARD
import flash.events.KeyboardEvent;
import flash.Lib;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.system.replay.CodeValuePair;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;
import flixel.input.FlxInput;

/**
 * Keeps track of what keys are pressed and how with handy Bools or strings.
 */
@:allow(flixel.system.replay.FlxReplay)
@:allow(flixel.input.keyboard.FlxKeyList)
class FlxKeyboard implements IFlxInputManager
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
	 * List of keys on which preventDefault() is called, useful on HTML5 to stop 
	 * the browser from scrolling when pressing the up or down key for example.
	 */
	#if bitfive
	public var preventDefaultKeys:Array<FlxKey> = [UP, DOWN, LEFT, RIGHT, TAB, SPACE];
	#end
	
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
	 * Internal storage of input keys as an array, for efficient iteration.
	 */
	private var _keyListArray:Array<FlxKeyInput>;
	/**
	 * Internal storage of input keys as a map, for efficient indexing.
	 */
	private var _keyListMap:Map<Int, FlxKeyInput>;
	
	/**
	 * Function and numpad keycodes on native targets are incorrect, 
	 * this workaround fixes that. Thanks @HaxePunk!
	 * @see https://github.com/openfl/openfl-native/issues/193
	 */
	#if !(flash || js)
	private var _nativeCorrection:Map<String, Int>;
	#end
	
	/**
	 * Check to see if at least one key from an array of keys is pressed.
	 * Example: FlxG.keys.anyPressed([UP, W, SPACE]) - having them in an array is handy for configurable keys!
	 * 
	 * @param	KeyArray 	An array of key names
	 * @return	Whether at least one of the keys passed in is pressed.
	 */
	public inline function anyPressed(KeyArray:Array<FlxKey>):Bool
	{ 
		return checkKeyArrayState(KeyArray, PRESSED);
	}
	
	/**
	 * Check to see if at least one key from an array of keys was just pressed.
	 * Example: FlxG.keys.anyJustPressed([UP, W, SPACE]) - having them in an array is handy for configurable keys!
	 * 
	 * @param	KeyArray 	An array of key names
	 * @return	Whether at least one of the keys passed was just pressed.
	 */
	public inline function anyJustPressed(KeyArray:Array<FlxKey>):Bool
	{ 
		return checkKeyArrayState(KeyArray, JUST_PRESSED);
	}
	
	/**
	 * Check to see if at least one key from an array of keys was just released.
	 * Example: FlxG.keys.anyJustReleased([UP, W, SPACE]) - having them in an array is handy for configurable keys!
	 * 
	 * @param	KeyArray 	An array of key names
	 * @return	Whether at least one of the keys passed was just released.
	 */
	public inline function anyJustReleased(KeyArray:Array<FlxKey>):Bool
	{ 
		return checkKeyArrayState(KeyArray, JUST_RELEASED);
	}
	
	/**
	 * Get the first key which is currently pressed.
	 * 
	 * @return	The the first pressed FlxKey
	 */
	public function firstPressed():FlxKey
	{
		for (key in _keyListArray)
		{
			if (key != null && key.pressed)
			{
				return key.ID;
			}
		}
		return FlxKey.NONE;
	}
	
	/**
	 * Get the name of the first key which has just been pressed.
	 * 
	 * @return	The name of the key or "" if none could be found.
	 */
	public function firstJustPressed():FlxKey
	{
		for (key in _keyListArray)
		{
			if (key != null && key.justPressed)
			{
				return key.ID;
			}
		}
		return "";
	}
	
	/**
	 * Get the name of the first key which has just been released.
	 * 
	 * @return	The name of the key or "" if none could be found.
	 */
	public function firstJustReleased():FlxKey
	{
		for (key in _keyListArray)
		{
			if (key != null && key.justReleased)
			{
				return key.ID;
			}
		}
		return "";
	}
	
	/**
	 * Check the status of a single of key
	 * 
	 * @param	KeyCode		KeyCode to be checked.
	 * @param	Status		The key state to check for.
	 * @return	Whether the provided key has the specified status.
	 */
	public function checkStatus(KeyCode:FlxKey, Status:FlxInputState):Bool
	{
		var key:FlxKeyInput = getKey(KeyCode);
		
		if (key != null)
		{
			if (key.hasState(Status))
			{
				return true;
			}
		}
		#if !FLX_NO_DEBUG
		else
		{
			throw 'Invalid key code: $KeyCode.';
		}
		#end
		
		return false;
	}

	/**
	 * Get an Array of FlxKey that are in a pressed state
	 * 
	 * @return	Array of keys that are currently pressed.
	 */
	public function getIsDown():Array<FlxKeyInput>
	{
		var keysDown = new Array<FlxKeyInput>();
		
		for (key in _keyListArray)
		{
			if (key != null && key.pressed)
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
		_keyListArray = null;
		_keyListMap = null;
	}
	
	/**
	 * Resets all the keys.
	 */
	public function reset():Void
	{
		for (key in _keyListArray)
		{
			if (key != null)
			{
				key.release();
			}
		}
	}
	
	@:allow(flixel.FlxG)
	private function new()
	{
		_keyListArray = new Array<FlxKeyInput>();
		_keyListMap = new Map<Int, FlxKeyInput>();
		
		for (code in [8, 9, 13, 16, 17, 19, 20, 27, 45, 46, 144, 145, 219, 220, 221, 222, 301]
			.concat([for (i in 186...193) i])
			.concat([for (i in 32...41) i])
			.concat([for (i in 48...58) i])
			.concat([for (i in 65...91) i])
			.concat([for (i in 96...108) i])
			.concat([for (i in 109...127) i]))
		{
			var input:FlxKeyInput = new FlxKeyInput(code);
			_keyListArray.push(input);
			_keyListMap.set(code, input);
		}
		
		#if !(flash || js)
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
		
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		pressed = new FlxKeyList(PRESSED);
		justPressed = new FlxKeyList(JUST_PRESSED);
		justReleased = new FlxKeyList(JUST_RELEASED);
	}
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	private function update():Void
	{
		for (key in _keyListArray)
		{
			if (key != null) 
			{
				key.update();
			}
		}
	}
	
	/**
	 * Helper function to check the status of an array of keys
	 * 
	 * @param	KeyArray	An array of keys as Strings
	 * @param	State		The key state to check for
	 * @return	Whether at least one of the keys has the specified status
	 */
	private function checkKeyArrayState(KeyArray:Array<FlxKey>, State:FlxInputState):Bool
	{
		if (KeyArray == null)
		{
			return false;
		}
		
		for (code in KeyArray)
		{
			var key:FlxKeyInput = getKey(code);
			
			if (key != null)
			{
				if (key.hasState(State))
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
	private function onKeyUp(event:KeyboardEvent):Void
	{
		var c:Int = resolveKeyCode(event);
		handlePreventDefault(c, event);
		
		// Debugger toggle
		#if !FLX_NO_DEBUG
		if (FlxG.game.debugger != null && inKeyArray(FlxG.debugger.toggleKeys, c))
		{
			FlxG.debugger.visible = !FlxG.debugger.visible;
		}
		#end
		
		if (enabled) 
		{
			updateKeyStates(c, false);
		}
	}
	
	/**
	 * Internal event handler for input and focus.
	 */
	private function onKeyDown(event:KeyboardEvent):Void
	{
		var c:Int = resolveKeyCode(event);
		handlePreventDefault(c, event);
		
		// Attempted to cancel the replay?
		#if FLX_RECORD
		if (FlxG.game.replaying && !inKeyArray(FlxG.debugger.toggleKeys, c) && inKeyArray(FlxG.vcr.cancelKeys, c))
		{
			FlxG.vcr.cancelReplay();
		}
		#end
		
		if (enabled) 
		{
			updateKeyStates(c, true);
		}
	}
	
	private function handlePreventDefault(keyCode:Int, event:KeyboardEvent):Void
	{
		#if bitfive
		var key:FlxKeyInput = getKey(keyCode);
		if (key != null && preventDefaultKeys != null && preventDefaultKeys.indexOf(key.ID) != -1)
		{
			event.preventDefault();
		}
		#end
	}
	
	/**
	 * A Helper function to check whether an array of keycodes contains 
	 * a certain key safely (returns false if the array is null).
	 */ 
	private function inKeyArray(KeyArray:Array<FlxKey>, Key:FlxKey):Bool
	{
		if (KeyArray == null)
		{
			return false;
		}
		else
		{
			for (key in KeyArray)
			{
				if (key == Key || key == "ANY")
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
		var key:FlxKeyInput = getKey(KeyCode);
		
		if (key != null) 
		{
			if (Down)
			{
				key.press();
			}
			else
			{
				key.release();
			}
		}
	}
	
	private inline function onFocus():Void {}

	private inline function onFocusLost():Void
	{
		reset();
	}
	
	/**
	 * Return a key from the key list, if found. Will return null if not found.
	 */
	@:allow(flixel.input.keyboard.FlxKeyList.get_ANY)
	private inline function getKey(KeyCode:Int):FlxKeyInput
	{
		return _keyListMap.get(KeyCode);
	}
	
	/** Replay functions **/
	
	/**
	 * If any keys are not "released",
	 * this function will return an array indicating
	 * which keys are pressed and what state they are in.
	 * 
	 * @return	An array of key state data. Null if there is no data.
	 */
	private function record():Array<CodeValuePair>
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
	private function playback(Record:Array<CodeValuePair>):Void
	{
		var i:Int = 0;
		var l:Int = Record.length;
		var o:CodeValuePair;
		var o2:FlxKeyInput;
		
		while (i < l)
		{
			o = Record[i++];
			o2 = getKey(o.code);
			o2.current = o.value;
		}
	}
}

typedef FlxKeyInput = FlxInput<Int>;

#end