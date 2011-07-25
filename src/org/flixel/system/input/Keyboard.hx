package org.flixel.system.input;

import flash.events.KeyboardEvent;

/**
 * Keeps track of what keys are pressed and how with handy Bools or strings.
 */
class Keyboard extends Input
{
	public var ESCAPE:Bool;
	public var F1:Bool;
	public var F2:Bool;
	public var F3:Bool;
	public var F4:Bool;
	public var F5:Bool;
	public var F6:Bool;
	public var F7:Bool;
	public var F8:Bool;
	public var F9:Bool;
	public var F10:Bool;
	public var F11:Bool;
	public var F12:Bool;
	public var ONE:Bool;
	public var TWO:Bool;
	public var THREE:Bool;
	public var FOUR:Bool;
	public var FIVE:Bool;
	public var SIX:Bool;
	public var SEVEN:Bool;
	public var EIGHT:Bool;
	public var NINE:Bool;
	public var ZERO:Bool;
	public var NUMPADONE:Bool;
	public var NUMPADTWO:Bool;
	public var NUMPADTHREE:Bool;
	public var NUMPADFOUR:Bool;
	public var NUMPADFIVE:Bool;
	public var NUMPADSIX:Bool;
	public var NUMPADSEVEN:Bool;
	public var NUMPADEIGHT:Bool;
	public var NUMPADNINE:Bool;
	public var NUMPADZERO:Bool;
	public var PAGEUP:Bool;
	public var PAGEDOWN:Bool;
	public var HOME:Bool;
	public var END:Bool;
	public var INSERT:Bool;
	public var MINUS:Bool;
	public var NUMPADMINUS:Bool;
	public var PLUS:Bool;
	public var NUMPADPLUS:Bool;
	public var DELETE:Bool;
	public var BACKSPACE:Bool;
	public var TAB:Bool;
	public var Q:Bool;
	public var W:Bool;
	public var E:Bool;
	public var R:Bool;
	public var T:Bool;
	public var Y:Bool;
	public var U:Bool;
	public var I:Bool;
	public var O:Bool;
	public var P:Bool;
	public var LBRACKET:Bool;
	public var RBRACKET:Bool;
	public var BACKSLASH:Bool;
	public var CAPSLOCK:Bool;
	public var A:Bool;
	public var S:Bool;
	public var D:Bool;
	public var F:Bool;
	public var G:Bool;
	public var H:Bool;
	public var J:Bool;
	public var K:Bool;
	public var L:Bool;
	public var SEMICOLON:Bool;
	public var QUOTE:Bool;
	public var ENTER:Bool;
	public var SHIFT:Bool;
	public var Z:Bool;
	public var X:Bool;
	public var C:Bool;
	public var V:Bool;
	public var B:Bool;
	public var N:Bool;
	public var M:Bool;
	public var COMMA:Bool;
	public var PERIOD:Bool;
	public var NUMPADPERIOD:Bool;
	public var SLASH:Bool;
	public var NUMPADSLASH:Bool;
	public var CONTROL:Bool;
	public var ALT:Bool;
	public var SPACE:Bool;
	public var UP:Bool;
	public var DOWN:Bool;
	public var LEFT:Bool;
	public var RIGHT:Bool;

	public function new()
	{
		super();
		
		var i:UInt;
		
		//LETTERS
		i = 65;
		while (i <= 90)
		{
			addKey(String.fromCharCode(i),i++);
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
		addKey("NUMPADNINE",i++);
		addKey("PAGEUP", 33);
		addKey("PAGEDOWN", 34);
		addKey("HOME", 36);
		addKey("END", 35);
		addKey("INSERT", 45);
		
		//FUNCTION KEYS
		i = 1;
		while (i <= 12)
		{
			addKey("F"+i,111+(i++));
		}
		
		//SPECIAL KEYS + PUNCTUATION
		addKey("ESCAPE",27);
		addKey("MINUS",189);
		addKey("NUMPADMINUS",109);
		addKey("PLUS",187);
		addKey("NUMPADPLUS",107);
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
		addKey("NUMPADPERIOD",110);
		addKey("SLASH",191);
		addKey("NUMPADSLASH",191);
		addKey("CONTROL",17);
		addKey("ALT",18);
		addKey("SPACE",32);
		addKey("UP",38);
		addKey("DOWN",40);
		addKey("LEFT",37);
		addKey("RIGHT",39);
		addKey("TAB",9);
	}
	
	/**
	 * Event handler so FlxGame can toggle keys.
	 * @param	FlashEvent	A <code>KeyboardEvent</code> object.
	 */
	public function handleKeyDown(FlashEvent:KeyboardEvent):Void
	{
		var o:Dynamic = _map[FlashEvent.keyCode];
		if(o == null) return;
		if(o.current > 0) o.current = 1;
		else o.current = 2;
		Reflect.setField(this, o.name, true);
	}
	
	/**
	 * Event handler so FlxGame can toggle keys.
	 * @param	FlashEvent	A <code>KeyboardEvent</code> object.
	 */
	public function handleKeyUp(FlashEvent:KeyboardEvent):Void
	{
		var object:Dynamic = _map[FlashEvent.keyCode];
		if(object == null) return;
		if(object.current > 0) object.current = -1;
		else object.current = 0;
		//this[object.name] = false;
		Reflect.setField(this, object.name, false);
	}
}