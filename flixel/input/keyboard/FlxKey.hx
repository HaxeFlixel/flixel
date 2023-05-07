package flixel.input.keyboard;

import flixel.system.macros.FlxMacroUtil;

/**
 * Maps enum values and strings to integer keycodes.
 */
enum abstract FlxKey(Int) from Int to Int
{
	public static var fromStringMap(default, null):Map<String, FlxKey> = FlxMacroUtil.buildMap("flixel.input.keyboard.FlxKey");
	public static var toStringMap(default, null):Map<FlxKey, String> = FlxMacroUtil.buildMap("flixel.input.keyboard.FlxKey", true);
	// Key Indicies
	var ANY = -2;
	var NONE = -1;
	var A = 65;
	var B = 66;
	var C = 67;
	var D = 68;
	var E = 69;
	var F = 70;
	var G = 71;
	var H = 72;
	var I = 73;
	var J = 74;
	var K = 75;
	var L = 76;
	var M = 77;
	var N = 78;
	var O = 79;
	var P = 80;
	var Q = 81;
	var R = 82;
	var S = 83;
	var T = 84;
	var U = 85;
	var V = 86;
	var W = 87;
	var X = 88;
	var Y = 89;
	var Z = 90;
	var ZERO = 48;
	var ONE = 49;
	var TWO = 50;
	var THREE = 51;
	var FOUR = 52;
	var FIVE = 53;
	var SIX = 54;
	var SEVEN = 55;
	var EIGHT = 56;
	var NINE = 57;
	var PAGEUP = 33;
	var PAGEDOWN = 34;
	var HOME = 36;
	var END = 35;
	var INSERT = 45;
	var ESCAPE = 27;
	var MINUS = 189;
	var PLUS = 187;
	var DELETE = 46;
	var BACKSPACE = 8;
	var LBRACKET = 219;
	var RBRACKET = 221;
	var BACKSLASH = 220;
	var CAPSLOCK = 20;
	var SCROLL_LOCK = 145;
	var NUMLOCK = 144;
	var SEMICOLON = 186;
	var QUOTE = 222;
	var ENTER = 13;
	var SHIFT = 16;
	var COMMA = 188;
	var PERIOD = 190;
	var SLASH = 191;
	var GRAVEACCENT = 192;
	var CONTROL = 17;
	var ALT = 18;
	var SPACE = 32;
	var UP = 38;
	var DOWN = 40;
	var LEFT = 37;
	var RIGHT = 39;
	var TAB = 9;
	var WINDOWS = 15;
	var MENU = 302;
	var PRINTSCREEN = 301;
	var BREAK = 19;
	var F1 = 112;
	var F2 = 113;
	var F3 = 114;
	var F4 = 115;
	var F5 = 116;
	var F6 = 117;
	var F7 = 118;
	var F8 = 119;
	var F9 = 120;
	var F10 = 121;
	var F11 = 122;
	var F12 = 123;
	var NUMPADZERO = 96;
	var NUMPADONE = 97;
	var NUMPADTWO = 98;
	var NUMPADTHREE = 99;
	var NUMPADFOUR = 100;
	var NUMPADFIVE = 101;
	var NUMPADSIX = 102;
	var NUMPADSEVEN = 103;
	var NUMPADEIGHT = 104;
	var NUMPADNINE = 105;
	var NUMPADMINUS = 109;
	var NUMPADPLUS = 107;
	var NUMPADPERIOD = 110;
	var NUMPADMULTIPLY = 106;
	var NUMPADSLASH = 111;

	@:from
	public static inline function fromString(s:String)
	{
		s = s.toUpperCase();
		return fromStringMap.exists(s) ? fromStringMap.get(s) : NONE;
	}

	@:to
	public inline function toString():String
	{
		return toStringMap.get(this);
	}
}
