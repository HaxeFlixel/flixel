package flixel.system.input;

import flixel.FlxG;
import flixel.FlxGame;
import flash.Lib;
import flash.events.KeyboardEvent;

/**
 * Keeps track of what keys are pressed and how with handy Bools or strings.
 */
class FlxKeyboard extends FlxInputStates implements IFlxInput
{
	public var ESCAPE		(get_ESCAPE, never) : Bool; function get_ESCAPE()		{ return pressed("ESCAPE"); }
	public var F1			(get_F1, never) : Bool; function get_F1()			{ return pressed("F1"); }
	public var F2			(get_F2, never) : Bool; function get_F2()			{ return pressed("F2"); }
	public var F3			(get_F3, never) : Bool; function get_F3()			{ return pressed("F3"); }
	public var F4			(get_F4, never) : Bool; function get_F4()			{ return pressed("F4"); }
	public var F5			(get_F5, never) : Bool; function get_F5()			{ return pressed("F5"); }
	public var F6			(get_F6, never) : Bool; function get_F6()			{ return pressed("F6"); }
	public var F7			(get_F7, never) : Bool; function get_F7()			{ return pressed("F7"); }
	public var F8			(get_F8, never) : Bool; function get_F8()			{ return pressed("F8"); }
	public var F9			(get_F9, never) : Bool; function get_F9()			{ return pressed("F9"); }
	public var F10			(get_F10, never) : Bool; function get_F10()			{ return pressed("F10"); }
	public var F11			(get_F11, never) : Bool; function get_F11()			{ return pressed("F11"); }
	public var F12			(get_F12, never) : Bool; function get_F12()			{ return pressed("F12"); }
	public var ONE			(get_ONE, never) : Bool; function get_ONE()			{ return pressed("ONE"); }
	public var TWO			(get_TWO, never) : Bool; function get_TWO()			{ return pressed("TWO"); }
	public var THREE		(get_THREE, never) : Bool; function get_THREE()		{ return pressed("THREE"); }
	public var FOUR			(get_FOUR, never) : Bool; function get_FOUR()			{ return pressed("FOUR"); }
	public var FIVE			(get_FIVE, never) : Bool; function get_FIVE()			{ return pressed("FIVE"); }
	public var SIX			(get_SIX, never) : Bool; function get_SIX()			{ return pressed("SIX"); }
	public var SEVEN		(get_SEVEN, never) : Bool; function get_SEVEN()		{ return pressed("SEVEN"); }
	public var EIGHT		(get_EIGHT, never) : Bool; function get_EIGHT()		{ return pressed("EIGHT"); }
	public var NINE			(get_NINE, never) : Bool; function get_NINE()			{ return pressed("NINE"); }
	public var ZERO			(get_ZERO, never) : Bool; function get_ZERO()			{ return pressed("ZERO"); }
	public var NUMPADONE	(get_NUMPADONE, never) : Bool; function get_NUMPADONE()	{ return pressed("NUMPADONE"); }
	public var NUMPADTWO	(get_NUMPADTWO, never) : Bool; function get_NUMPADTWO()	{ return pressed("NUMPADTWO"); }
	public var NUMPADTHREE	(get_NUMPADTHREE, never) : Bool; function get_NUMPADTHREE()	{ return pressed("NUMPADTHREE"); }
	public var NUMPADFOUR	(get_NUMPADFOUR, never) : Bool; function get_NUMPADFOUR()	{ return pressed("NUMPADFOUR"); }
	public var NUMPADFIVE	(get_NUMPADFIVE, never) : Bool; function get_NUMPADFIVE()	{ return pressed("NUMPADFIVE"); }
	public var NUMPADSIX	(get_NUMPADSIX, never) : Bool; function get_NUMPADSIX()	{ return pressed("NUMPADSIX"); }
	public var NUMPADSEVEN	(get_NUMPADSEVEN, never) : Bool; function get_NUMPADSEVEN()	{ return pressed("NUMPADSEVEN"); }
	public var NUMPADEIGHT	(get_NUMPADEIGHT, never) : Bool; function get_NUMPADEIGHT()	{ return pressed("NUMPADEIGHT"); }
	public var NUMPADNINE	(get_NUMPADNINE, never) : Bool; function get_NUMPADNINE()	{ return pressed("NUMPADNINE"); }
	public var NUMPADZERO	(get_NUMPADZERO, never) : Bool; function get_NUMPADZERO()	{ return pressed("NUMPADZERO"); }
	public var PAGEUP		(get_PAGEUP, never) : Bool; function get_PAGEUP()		{ return pressed("PAGEUP"); }
	public var PAGEDOWN		(get_PAGEDOWN, never) : Bool; function get_PAGEDOWN()		{ return pressed("PAGEDOWN"); }
	public var HOME			(get_HOME, never) : Bool; function get_HOME()			{ return pressed("HOME"); }
	public var END			(get_END, never) : Bool; function get_END()			{ return pressed("END"); }
	public var INSERT		(get_INSERT, never) : Bool; function get_INSERT()		{ return pressed("INSERT"); }
	public var MINUS		(get_MINUS, never) : Bool; function get_MINUS()		{ return pressed("MINUS"); }
	public var NUMPADMINUS	(get_NUMPADMINUS, never) : Bool; function get_NUMPADMINUS()	{ return pressed("NUMPADMINUS"); }
	public var PLUS			(get_PLUS, never) : Bool; function get_PLUS()			{ return pressed("PLUS"); }
	public var NUMPADPLUS	(get_NUMPADPLUS, never) : Bool; function get_NUMPADPLUS()	{ return pressed("NUMPADPLUS"); }
	public var DELETE		(get_DELETE, never) : Bool; function get_DELETE()		{ return pressed("DELETE"); }
	public var BACKSPACE	(get_BACKSPACE, never) : Bool; function get_BACKSPACE()	{ return pressed("BACKSPACE"); }
	public var TAB			(get_TAB, never) : Bool; function get_TAB()			{ return pressed("TAB"); }
	public var Q			(get_Q, never) : Bool; function get_Q()			{ return pressed("Q"); }
	public var W			(get_W, never) : Bool; function get_W()			{ return pressed("W"); }
	public var E			(get_E, never) : Bool; function get_E()			{ return pressed("E"); }
	public var R			(get_R, never) : Bool; function get_R()			{ return pressed("R"); }
	public var T			(get_T, never) : Bool; function get_T()			{ return pressed("T"); }
	public var Y			(get_Y, never) : Bool; function get_Y()			{ return pressed("Y"); }
	public var U			(get_U, never) : Bool; function get_U()			{ return pressed("U"); }
	public var I			(get_I, never) : Bool; function get_I()			{ return pressed("I"); }
	public var O			(get_O, never) : Bool; function get_O()			{ return pressed("O"); }
	public var P			(get_P, never) : Bool; function get_P()			{ return pressed("P"); }
	public var LBRACKET		(get_LBRACKET, never) : Bool; function get_LBRACKET()		{ return pressed("LBRACKET"); }
	public var RBRACKET		(get_RBRACKET, never) : Bool; function get_RBRACKET()		{ return pressed("RBRACKET"); }
	public var BACKSLASH	(get_BACKSLASH, never) : Bool; function get_BACKSLASH()	{ return pressed("BACKSLASH"); }
	public var CAPSLOCK		(get_CAPSLOCK, never) : Bool; function get_CAPSLOCK()		{ return pressed("CAPSLOCK"); }
	public var A			(get_A, never) : Bool; function get_A()			{ return pressed("A"); }
	public var S			(get_S, never) : Bool; function get_S()			{ return pressed("S"); }
	public var D			(get_D, never) : Bool; function get_D()			{ return pressed("D"); }
	public var F			(get_F, never) : Bool; function get_F()			{ return pressed("F"); }
	public var G			(get_G, never) : Bool; function get_G()			{ return pressed("G"); }
	public var H			(get_H, never) : Bool; function get_H()			{ return pressed("H"); }
	public var J			(get_J, never) : Bool; function get_J()			{ return pressed("J"); }
	public var K			(get_K, never) : Bool; function get_K()			{ return pressed("K"); }
	public var L			(get_L, never) : Bool; function get_L()			{ return pressed("L"); }
	public var SEMICOLON	(get_SEMICOLON, never) : Bool; function get_SEMICOLON()	{ return pressed("SEMICOLON"); }
	public var QUOTE		(get_QUOTE, never) : Bool; function get_QUOTE()		{ return pressed("QUOTE"); }
	public var ENTER		(get_ENTER, never) : Bool; function get_ENTER()		{ return pressed("ENTER"); }
	public var SHIFT		(get_SHIFT, never) : Bool; function get_SHIFT()		{ return pressed("SHIFT"); }
	public var Z			(get_Z, never) : Bool; function get_Z()			{ return pressed("Z"); }
	public var X			(get_X, never) : Bool; function get_X()			{ return pressed("X"); }
	public var C			(get_C, never) : Bool; function get_C()			{ return pressed("C"); }
	public var V			(get_V, never) : Bool; function get_V()			{ return pressed("V"); }
	public var B			(get_B, never) : Bool; function get_B()			{ return pressed("B"); }
	public var N			(get_N, never) : Bool; function get_N()			{ return pressed("N"); }
	public var M			(get_M, never) : Bool; function get_M()			{ return pressed("M"); }
	public var COMMA		(get_COMMA, never) : Bool; function get_COMMA()		{ return pressed("COMMA"); }
	public var PERIOD		(get_PERIOD, never) : Bool; function get_PERIOD()		{ return pressed("PERIOD"); }
	public var NUMPADPERIOD	(get_NUMPADPERIOD, never) : Bool; function get_NUMPADPERIOD()	{ return pressed("NUMPADPERIOD"); }
	public var SLASH		(get_SLASH, never) : Bool; function get_SLASH()		{ return pressed("SLASH"); }
	public var NUMPADSLASH	(get_NUMPADSLASH, never) : Bool; function get_NUMPADSLASH()	{ return pressed("NUMPADSLASH"); }
	public var CONTROL		(get_CONTROL, never) : Bool; function get_CONTROL()		{ return pressed("CONTROL"); }
	public var ALT			(get_ALT, never) : Bool; function get_ALT()			{ return pressed("ALT"); }
	public var SPACE		(get_SPACE, never) : Bool; function get_SPACE()		{ return pressed("SPACE"); }
	public var UP			(get_UP, never) : Bool; function get_UP()			{ return pressed("UP"); }
	public var DOWN			(get_DOWN, never) : Bool; function get_DOWN()			{ return pressed("DOWN"); }
	public var LEFT			(get_LEFT, never) : Bool; function get_LEFT()			{ return pressed("LEFT"); }
	public var RIGHT		(get_RIGHT, never) : Bool; function get_RIGHT()		{ return pressed("RIGHT"); }
	
	public function new()
	{
		super();
		
		var i:Int;
		
		//LETTERS
		i = 65;
		while (i <= 90)
		{
			addKey(String.fromCharCode(i), i);
			i++;
		}
		
		//NUMBERS
		i = 48;
		addKey("ZERO",i++);
		addKey("ONE",i++);
		addKey("TWO",i++);
		addKey("THREE",i++);
		addKey("FOUR",i++);
		addKey("FIVE",i++);
		addKey("SIX",i++);
		addKey("SEVEN",i++);
		addKey("EIGHT",i++);
		addKey("NINE",i++);
		#if (flash || js)
		i = 96;
		addKey("NUMPADZERO",i++);
		addKey("NUMPADONE",i++);
		addKey("NUMPADTWO",i++);
		addKey("NUMPADTHREE",i++);
		addKey("NUMPADFOUR",i++);
		addKey("NUMPADFIVE",i++);
		addKey("NUMPADSIX",i++);
		addKey("NUMPADSEVEN",i++);
		addKey("NUMPADEIGHT",i++);
		addKey("NUMPADNINE", i++);
		#end
		addKey("PAGEUP", 33);
		addKey("PAGEDOWN", 34);
		addKey("HOME", 36);
		addKey("END", 35);
		addKey("INSERT", 45);
		
		//FUNCTION KEYS
		#if (flash || js)
		i = 1;
		while (i <= 12)
		{
			addKey("F"+i,111+(i++));
		}
		#end
		
		//SPECIAL KEYS + PUNCTUATION
		addKey("ESCAPE",27);
		addKey("MINUS",189);
		addKey("PLUS",187);
		addKey("DELETE",46);
		addKey("BACKSPACE",8);
		addKey("LBRACKET",219);
		addKey("RBRACKET",221);
		addKey("BACKSLASH",220);
		addKey("CAPSLOCK",20);
		addKey("SEMICOLON",186);
		addKey("QUOTE",222);
		addKey("ENTER",13);
		addKey("SHIFT",16);
		addKey("COMMA",188);
		addKey("PERIOD",190);
		addKey("SLASH",191);
		addKey("NUMPADSLASH",191);
		addKey("CONTROL",17);
		addKey("ALT",18);
		addKey("SPACE",32);
		addKey("UP",38);
		addKey("DOWN",40);
		addKey("LEFT",37);
		addKey("RIGHT",39);
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
	 * @param	FlashEvent	A <code>KeyboardEvent</code> object.
	 */
	private function onKeyUp(FlashEvent:KeyboardEvent):Void
	{
		#if !FLX_NO_DEBUG
		if (FlxG._game._debuggerUp && FlxG._game._debugger.watch.editing)
		{
			return;
		}
		#end
		
		#if !mobile
			var c:Int = FlashEvent.keyCode;
				
			#if !FLX_NO_DEBUG
			if ((FlxG._game._debugger != null) && (FlxG.debugger.toggleKeys != null && Lambda.indexOf(FlxG.debugger.toggleKeys, c) != -1))
			{
				FlxG.debugger.visible = !FlxG.debugger.visible;
				return;
			}
			#end
				
			if (!FlxG._game.tempDisableSoundHotKeys)
			{
				var code:String = String.fromCharCode(FlashEvent.charCode);
				if (FlxG.sound.keyMute != null && Lambda.indexOf(FlxG.sound.keyMute, c) != -1)
				{
					FlxG.sound.mute = !FlxG.sound.mute;
					if (FlxG.sound.volumeHandler != null)
					{
						FlxG.sound.volumeHandler(FlxG.sound.mute?0:FlxG.sound.volume);
					}
					
					#if !FLX_NO_SOUND_TRAY
					FlxG._game.showSoundTray();
					#end
					
					return;
				}
				else if (FlxG.sound.keyVolumeDown != null && Lambda.indexOf(FlxG.sound.keyVolumeDown, c) != -1)
				{
					FlxG.sound.mute = false;
					FlxG.sound.volume = FlxG.sound.volume - 0.1;
						
					#if !FLX_NO_SOUND_TRAY
					FlxG._game.showSoundTray();
					#end
					
					return;
				}
				else if (FlxG.sound.keyVolumeUp != null && Lambda.indexOf(FlxG.sound.keyVolumeUp, c) != -1) 
				{
					FlxG.sound.mute = false;
					FlxG.sound.volume = FlxG.sound.volume + 0.1;
					
					#if !FLX_NO_SOUND_TRAY
					FlxG._game.showSoundTray();
					#end
						
					return;
				}
			}
		#end
		
		#if FLX_RECORD
		if (FlxG._game._replaying)
		{
			return;
		}
		#end
		
		var object:FlxMapObject = _keyMap[FlashEvent.keyCode];
		
		if (object == null) 
			return;
		if (object.current > 0) 
			object.current = -1;
		else 
			object.current = 0;
			
		_keyBools.set(object.name, false);
	}
	
	/**
	 * Internal event handler for input and focus.
	 * @param	FlashEvent	Flash keyboard event.
	 */
	private function onKeyDown(FlashEvent:KeyboardEvent):Void
	{
		#if FLX_RECORD
		#if !FLX_NO_DEBUG
		if (FlxG._game._debuggerUp && FlxG._game._debugger.watch.editing)
		{
			return;
		}
		if (FlxG._game._replaying && (FlxG._game._replayCancelKeys != null) && (FlxG._game._debugger == null) && (FlashEvent.keyCode != 192) && (FlashEvent.keyCode != 220))
		#else
		if (FlxG._game._replaying && (FlxG._game._replayCancelKeys != null) && (FlashEvent.keyCode != 192) && (FlashEvent.keyCode != 220))
		#end
		{
			var cancel:Bool = false;
			var replayCancelKey:String;
			var i:Int = 0;
			var l:Int = FlxG._game._replayCancelKeys.length;
			while(i < l)
			{
				replayCancelKey = FlxG._game._replayCancelKeys[i++];
				if ((replayCancelKey == "ANY") || (getKeyCode(replayCancelKey) == Std.int(FlashEvent.keyCode)))
				{
					if (FlxG._game._replayCallback != null)
					{
						FlxG._game._replayCallback();
						FlxG._game._replayCallback = null;
					}
					else
					{
						FlxG.vcr.stopReplay();
					}
					break;
				}
			}
			return;
		}
		#end
		
		var o:FlxMapObject = _keyMap[FlashEvent.keyCode];
		if (o == null) return;
		if(o.current > 0) o.current = 1;
		else o.current = 2;
		_keyBools.set(o.name, true);
	}

	public function onFocus( ):Void
	{
		
	}

	public function onFocusLost( ):Void
	{
		reset();
	}

	public function toString( ):String
	{
		return "Keyboard";
	}

}