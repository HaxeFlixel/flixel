package flixel.input.keyboard;

/**
 * Maps enum values and strings to integer keycodes.
 */
@:enum
abstract FlxKey(Int) from Int to Int
{
	public static var keyNameMap:Map<String, FlxKey> = [
		"ANY" =>            ANY,
		"A" =>              A,
		"B" =>              B,
		"C" =>              C,
		"D" =>              D,
		"E" =>              E,
		"F" =>              F,
		"G" =>              G,
		"H" =>              H,
		"I" =>              I,
		"J" =>              J,
		"K" =>              K,
		"L" =>              L,
		"M" =>              M,
		"N" =>              N,
		"O" =>              O,
		"P" =>              P,
		"Q" =>              Q,
		"R" =>              R,
		"S" =>              S,
		"T" =>              T,
		"U" =>              U,
		"V" =>              V,
		"W" =>              W,
		"X" =>              X,
		"Y" =>              Y,
		"Z" =>              Z,
		"ZERO" =>           ZERO,
		"ONE" =>            ONE,
		"TWO" =>            TWO,
		"THREE" =>          THREE,
		"FOUR" =>           FOUR,
		"FIVE" =>           FIVE,
		"SIX" =>            SIX,
		"SEVEN" =>          SEVEN,
		"EIGHT" =>          EIGHT,
		"NINE" =>           NINE,
		"PAGEUP" =>         PAGEUP,
		"PAGEDOWN" =>       PAGEDOWN,
		"HOME" =>           HOME,
		"END" =>            END,
		"INSERT" =>         INSERT,
		"ESCAPE" =>         ESCAPE,
		"MINUS" =>          MINUS,
		"PLUS" =>           PLUS,
		"DELETE" =>         DELETE,
		"BACKSPACE" =>      BACKSPACE,
		"LBRACKET" =>       LBRACKET,
		"RBRACKET" =>       RBRACKET,
		"BACKSLASH" =>      BACKSLASH,
		"CAPSLOCK" =>       CAPSLOCK,
		"SEMICOLON" =>      SEMICOLON,
		"QUOTE" =>          QUOTE,
		"ENTER" =>          ENTER,
		"SHIFT" =>          SHIFT,
		"COMMA" =>          COMMA,
		"PERIOD" =>         PERIOD,
		"SLASH" =>          SLASH,
		"NUMPADSLASH" =>    NUMPADSLASH,
		"GRAVEACCENT" =>    GRAVEACCENT,
		"CONTROL" =>        CONTROL,
		"ALT" =>            ALT,
		"SPACE" =>          SPACE,
		"UP" =>             UP,
		"DOWN" =>           DOWN,
		"LEFT" =>           LEFT,
		"RIGHT" =>          RIGHT,
		"TAB" =>            TAB,
		"PRINTSCREEN" =>    PRINTSCREEN,
		"F1" =>             F1,
		"F2" =>             F2,
		"F3" =>             F3,
		"F4" =>             F4,
		"F5" =>             F5,
		"F6" =>             F6,
		"F7" =>             F7,
		"F8" =>             F8,
		"F9" =>             F9,
		"F10" =>            F10,
		"F11" =>            F11,
		"F12" =>            F12,
		"NUMPADZERO" =>     NUMPADZERO,
		"NUMPADONE" =>      NUMPADONE,
		"NUMPADTWO" =>      NUMPADTWO,
		"NUMPADTHREE" =>    NUMPADTHREE,
		"NUMPADFOUR" =>     NUMPADFOUR,
		"NUMPADFIVE" =>     NUMPADFIVE,
		"NUMPADSIX" =>      NUMPADSIX,
		"NUMPADSEVEN" =>    NUMPADSEVEN,
		"NUMPADEIGHT" =>    NUMPADEIGHT,
		"NUMPADNINE" =>     NUMPADNINE,
		"NUMPADMINUS" =>    NUMPADMINUS,
		"NUMPADPLUS" =>     NUMPADPLUS,
		"NUMPADPERIOD" =>   NUMPADPERIOD,
		"NUMPADMULTIPLY" => NUMPADMULTIPLY
	];
	
	// Key Indicies
	var ANY            = -2;
	var NONE           = -1;
	var A              = 65;
	var B              = 66;
	var C              = 67;
	var D              = 68;
	var E              = 69;
	var F              = 70;
	var G              = 71;
	var H              = 72;
	var I              = 73;
	var J              = 74;
	var K              = 75;
	var L              = 76;
	var M              = 77;
	var N              = 78;
	var O              = 79;
	var P              = 80;
	var Q              = 81;
	var R              = 82;
	var S              = 83;
	var T              = 84;
	var U              = 85;
	var V              = 86;
	var W              = 87;
	var X              = 88;
	var Y              = 89;
	var Z              = 90;
	var ZERO           = 48;
	var ONE            = 49;
	var TWO            = 50;
	var THREE          = 51;
	var FOUR           = 52;
	var FIVE           = 53;
	var SIX            = 54;
	var SEVEN          = 55;
	var EIGHT          = 56;
	var NINE           = 57;
	var PAGEUP         = 33;
	var PAGEDOWN       = 34;
	var HOME           = 36;
	var END            = 35;
	var INSERT         = 45;
	var ESCAPE         = 27;
	var MINUS          = 189;
	var PLUS           = 187;
	var DELETE         = 46;
	var BACKSPACE      = 8;
	var LBRACKET       = 219;
	var RBRACKET       = 221;
	var BACKSLASH      = 220;
	var CAPSLOCK       = 20;
	var SEMICOLON      = 186;
	var QUOTE          = 222;
	var ENTER          = 13;
	var SHIFT          = 16;
	var COMMA          = 188;
	var PERIOD         = 190;
	var SLASH          = 191;
	var NUMPADSLASH    = 191;
	var GRAVEACCENT    = 192;
	var CONTROL        = 17;
	var ALT            = 18;
	var SPACE          = 32;
	var UP             = 38;
	var DOWN           = 40;
	var LEFT           = 37;
	var RIGHT          = 39;
	var TAB            = 9;
	var PRINTSCREEN    = 301;
	var F1             = 112;
	var F2             = 113;
	var F3             = 114;
	var F4             = 115;
	var F5             = 116;
	var F6             = 117;
	var F7             = 118;
	var F8             = 119;
	var F9             = 120;
	var F10            = 121;
	var F11            = 122;
	var F12            = 123;
	var NUMPADZERO     = 96;
	var NUMPADONE      = 97;
	var NUMPADTWO      = 98;
	var NUMPADTHREE    = 99;
	var NUMPADFOUR     = 100;
	var NUMPADFIVE     = 101;
	var NUMPADSIX      = 102;
	var NUMPADSEVEN    = 103;
	var NUMPADEIGHT    = 104;
	var NUMPADNINE     = 105;
	var NUMPADMINUS    = 109;
	var NUMPADPLUS     = 107;
	var NUMPADPERIOD   = 110;
	var NUMPADMULTIPLY = 106;
	
	@:from
	public static inline function fromString(s:String)
	{
		s = s.toUpperCase();
		return keyNameMap.exists(s) ? keyNameMap.get(s) : NONE;
	}
	
	@:to
	public static function toString(i:Int):String
	{
		for (key in keyNameMap.keys())
		{
			if (i == keyNameMap.get(key))
			{
				return key;
			}
		}
		return "NONE";
	}
}