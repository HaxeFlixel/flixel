package flixel.system.input.keyboard;

#if !FLX_NO_KEYBOARD
import flixel.FlxG;
import flixel.FlxGame;
import flash.Lib;
import flash.events.KeyboardEvent;
import flixel.system.input.keyboard.FlxKey;

/**
 * Keeps track of what keys are pressed and how with handy Bools or strings.
 */
class FlxKeyboard extends FlxInputStates implements IFlxInput
{
	public var ESCAPE		(get, never):Bool;	inline function get_ESCAPE()		{ return pressed("ESCAPE"); }
	public var F1			(get, never):Bool;	inline function get_F1()			{ return pressed("F1"); }
	public var F2			(get, never):Bool;	inline function get_F2()			{ return pressed("F2"); }
	public var F3			(get, never):Bool;	inline function get_F3()			{ return pressed("F3"); }
	public var F4			(get, never):Bool;	inline function get_F4()			{ return pressed("F4"); }
	public var F5			(get, never):Bool;	inline function get_F5()			{ return pressed("F5"); }
	public var F6			(get, never):Bool;	inline function get_F6()			{ return pressed("F6"); }
	public var F7			(get, never):Bool;	inline function get_F7()			{ return pressed("F7"); }
	public var F8			(get, never):Bool;	inline function get_F8()			{ return pressed("F8"); }
	public var F9			(get, never):Bool;	inline function get_F9()			{ return pressed("F9"); }
	public var F10			(get, never):Bool;	inline function get_F10()			{ return pressed("F10"); }
	public var F11			(get, never):Bool;	inline function get_F11()			{ return pressed("F11"); }
	public var F12			(get, never):Bool;	inline function get_F12()			{ return pressed("F12"); }
	public var ONE			(get, never):Bool;	inline function get_ONE()			{ return pressed("ONE"); }
	public var TWO			(get, never):Bool;	inline function get_TWO()			{ return pressed("TWO"); }
	public var THREE		(get, never):Bool;	inline function get_THREE()			{ return pressed("THREE"); }
	public var FOUR			(get, never):Bool;	inline function get_FOUR()			{ return pressed("FOUR"); }
	public var FIVE			(get, never):Bool;	inline function get_FIVE()			{ return pressed("FIVE"); }
	public var SIX			(get, never):Bool;	inline function get_SIX()			{ return pressed("SIX"); }
	public var SEVEN		(get, never):Bool;	inline function get_SEVEN()			{ return pressed("SEVEN"); }
	public var EIGHT		(get, never):Bool;	inline function get_EIGHT()			{ return pressed("EIGHT"); }
	public var NINE			(get, never):Bool;	inline function get_NINE()			{ return pressed("NINE"); }
	public var ZERO			(get, never):Bool;	inline function get_ZERO()			{ return pressed("ZERO"); }
	public var NUMPADONE	(get, never):Bool;	inline function get_NUMPADONE()		{ return pressed("NUMPADONE"); }
	public var NUMPADTWO	(get, never):Bool;	inline function get_NUMPADTWO()		{ return pressed("NUMPADTWO"); }
	public var NUMPADTHREE	(get, never):Bool;	inline function get_NUMPADTHREE()	{ return pressed("NUMPADTHREE"); }
	public var NUMPADFOUR	(get, never):Bool;	inline function get_NUMPADFOUR()	{ return pressed("NUMPADFOUR"); }
	public var NUMPADFIVE	(get, never):Bool;	inline function get_NUMPADFIVE()	{ return pressed("NUMPADFIVE"); }
	public var NUMPADSIX	(get, never):Bool;	inline function get_NUMPADSIX()		{ return pressed("NUMPADSIX"); }
	public var NUMPADSEVEN	(get, never):Bool;	inline function get_NUMPADSEVEN()	{ return pressed("NUMPADSEVEN"); }
	public var NUMPADEIGHT	(get, never):Bool;	inline function get_NUMPADEIGHT()	{ return pressed("NUMPADEIGHT"); }
	public var NUMPADNINE	(get, never):Bool;	inline function get_NUMPADNINE()	{ return pressed("NUMPADNINE"); }
	public var NUMPADZERO	(get, never):Bool;	inline function get_NUMPADZERO()	{ return pressed("NUMPADZERO"); }
	public var PAGEUP		(get, never):Bool;	inline function get_PAGEUP()		{ return pressed("PAGEUP"); }
	public var PAGEDOWN		(get, never):Bool;	inline function get_PAGEDOWN()		{ return pressed("PAGEDOWN"); }
	public var HOME			(get, never):Bool;	inline function get_HOME()			{ return pressed("HOME"); }
	public var END			(get, never):Bool;	inline function get_END()			{ return pressed("END"); }
	public var INSERT		(get, never):Bool;	inline function get_INSERT()		{ return pressed("INSERT"); }
	public var MINUS		(get, never):Bool;	inline function get_MINUS()			{ return pressed("MINUS"); }
	public var NUMPADMINUS	(get, never):Bool;	inline function get_NUMPADMINUS()	{ return pressed("NUMPADMINUS"); }
	public var PLUS			(get, never):Bool;	inline function get_PLUS()			{ return pressed("PLUS"); }
	public var NUMPADPLUS	(get, never):Bool;	inline function get_NUMPADPLUS()	{ return pressed("NUMPADPLUS"); }
	public var DELETE		(get, never):Bool;	inline function get_DELETE()		{ return pressed("DELETE"); }
	public var BACKSPACE	(get, never):Bool;	inline function get_BACKSPACE()		{ return pressed("BACKSPACE"); }
	public var TAB			(get, never):Bool;	inline function get_TAB()			{ return pressed("TAB"); }
	public var Q			(get, never):Bool;	inline function get_Q()				{ return pressed("Q"); }
	public var W			(get, never):Bool;	inline function get_W()				{ return pressed("W"); }
	public var E			(get, never):Bool;	inline function get_E()				{ return pressed("E"); }
	public var R			(get, never):Bool;	inline function get_R()				{ return pressed("R"); }
	public var T			(get, never):Bool;	inline function get_T()				{ return pressed("T"); }
	public var Y			(get, never):Bool;	inline function get_Y()				{ return pressed("Y"); }
	public var U			(get, never):Bool;	inline function get_U()				{ return pressed("U"); }
	public var I			(get, never):Bool;	inline function get_I()				{ return pressed("I"); }
	public var O			(get, never):Bool;	inline function get_O()				{ return pressed("O"); }
	public var P			(get, never):Bool;	inline function get_P()				{ return pressed("P"); }
	public var LBRACKET		(get, never):Bool;	inline function get_LBRACKET()		{ return pressed("LBRACKET"); }
	public var RBRACKET		(get, never):Bool;	inline function get_RBRACKET()		{ return pressed("RBRACKET"); }
	public var BACKSLASH	(get, never):Bool;	inline function get_BACKSLASH()		{ return pressed("BACKSLASH"); }
	public var CAPSLOCK		(get, never):Bool;	inline function get_CAPSLOCK()		{ return pressed("CAPSLOCK"); }
	public var A			(get, never):Bool;	inline function get_A()				{ return pressed("A"); }
	public var S			(get, never):Bool;	inline function get_S()				{ return pressed("S"); }
	public var D			(get, never):Bool;	inline function get_D()				{ return pressed("D"); }
	public var F			(get, never):Bool;	inline function get_F()				{ return pressed("F"); }
	public var G			(get, never):Bool;	inline function get_G()				{ return pressed("G"); }
	public var H			(get, never):Bool;	inline function get_H()				{ return pressed("H"); }
	public var J			(get, never):Bool;	inline function get_J()				{ return pressed("J"); }
	public var K			(get, never):Bool;	inline function get_K()				{ return pressed("K"); }
	public var L			(get, never):Bool;	inline function get_L()				{ return pressed("L"); }
	public var SEMICOLON	(get, never):Bool;	inline function get_SEMICOLON()		{ return pressed("SEMICOLON"); }
	public var QUOTE		(get, never):Bool;	inline function get_QUOTE()			{ return pressed("QUOTE"); }
	public var ENTER		(get, never):Bool;	inline function get_ENTER()			{ return pressed("ENTER"); }
	public var SHIFT		(get, never):Bool;	inline function get_SHIFT()			{ return pressed("SHIFT"); }
	public var Z			(get, never):Bool;	inline function get_Z()				{ return pressed("Z"); }
	public var X			(get, never):Bool;	inline function get_X()				{ return pressed("X"); }
	public var C			(get, never):Bool;	inline function get_C()				{ return pressed("C"); }
	public var V			(get, never):Bool;	inline function get_V()				{ return pressed("V"); }
	public var B			(get, never):Bool;	inline function get_B()				{ return pressed("B"); }
	public var N			(get, never):Bool;	inline function get_N()				{ return pressed("N"); }
	public var M			(get, never):Bool;	inline function get_M()				{ return pressed("M"); }
	public var COMMA		(get, never):Bool;	inline function get_COMMA()			{ return pressed("COMMA"); }
	public var PERIOD		(get, never):Bool;	inline function get_PERIOD()		{ return pressed("PERIOD"); }
	public var NUMPADPERIOD	(get, never):Bool;	inline function get_NUMPADPERIOD()	{ return pressed("NUMPADPERIOD"); }
	public var SLASH		(get, never):Bool;	inline function get_SLASH()			{ return pressed("SLASH"); }
	public var NUMPADSLASH	(get, never):Bool;	inline function get_NUMPADSLASH()	{ return pressed("NUMPADSLASH"); }
	public var CONTROL		(get, never):Bool;	inline function get_CONTROL()		{ return pressed("CONTROL"); }
	public var ALT			(get, never):Bool;	inline function get_ALT()			{ return pressed("ALT"); }
	public var SPACE		(get, never):Bool;	inline function get_SPACE()			{ return pressed("SPACE"); }
	public var UP			(get, never):Bool;	inline function get_UP()			{ return pressed("UP"); }
	public var DOWN			(get, never):Bool;	inline function get_DOWN()			{ return pressed("DOWN"); }
	public var LEFT			(get, never):Bool;	inline function get_LEFT()			{ return pressed("LEFT"); }
	public var RIGHT		(get, never):Bool;	inline function get_RIGHT()			{ return pressed("RIGHT"); }
	
	public var ANY			(get, never):Bool;	inline function get_ANY()			{ return anyKey(); }
	
	/**
	 * Whether or not keyboard input is currently enabled.
	 */
	public var enabled:Bool = true;

	public function new()
	{
		super();
		
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
		#if (flash || js)
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
		#end
		addKey("PAGEUP", 33);
		addKey("PAGEDOWN", 34);
		addKey("HOME", 36);
		addKey("END", 35);
		addKey("INSERT", 45);
		
		// FUNCTION KEYS
		#if (flash || js)
		i = 1;
		while (i <= 12)
		{
			addKey("F" + i, 111 + (i++));
		}
		#end
		
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
		
		#if (flash || js)
		addKey("NUMPADMINUS", 109);
		addKey("NUMPADPLUS", 107);
		addKey("NUMPADPERIOD", 110);
		#end
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	/**
	 * Event handler so FlxGame can toggle keys.
	 * 
	 * @param	FlashEvent	A <code>KeyboardEvent</code> object.
	 */
	private function onKeyUp(FlashEvent:KeyboardEvent):Void
	{
		var c:Int = FlashEvent.keyCode;
		
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
		
		// Sound tray controls
		
		// Mute key
		if (inKeyArray(FlxG.sound.muteKeys, c))
		{
			FlxG.sound.muted = !FlxG.sound.muted;
			
			if (FlxG.sound.volumeHandler != null)
			{
				FlxG.sound.volumeHandler(FlxG.sound.muted ? 0 : FlxG.sound.volume);
			}
			
			#if !(mobile && FLX_NO_SOUND_TRAY)
			if(FlxG.game.soundTray != null)
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
			
			#if !(mobile && FLX_NO_SOUND_TRAY)
			if(FlxG.game.soundTray != null)
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
			
			#if !(mobile && FLX_NO_SOUND_TRAY)
			if(FlxG.game.soundTray != null)
			{
				FlxG.game.soundTray.show();
			}
			#end
		}
		
		updateKeyStates(c, false);
	}
	
	/**
	 * Internal event handler for input and focus.
	 * 
	 * @param	FlashEvent	Flash keyboard event.
	 */
	private function onKeyDown(FlashEvent:KeyboardEvent):Void
	{
		var c:Int = FlashEvent.keyCode;
		
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
	
	/**
	 * A helper function to update the key states based on a keycode provided.
	 */
	inline private function updateKeyStates(KeyCode:Int, Down:Bool):Void
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
			
			_keyBools.set(obj.name, Down);
		}
	}
	
	inline public function onFocus( ):Void { }

	inline public function onFocusLost():Void
	{
		reset();
	}

	inline public function toString():String
	{
		return "FlxKeyboard";
	}
}
#end