package flixel.input.keyboard;

/**
 * A helper class for keyboard input.
 */
class FlxKey
{
	// Key States
	inline public static var JUST_RELEASED:Int = -1;
	inline public static var RELEASED     :Int =  0;
	inline public static var PRESSED      :Int =  1;
	inline public static var JUST_PRESSED :Int =  2;
	
	// Key Indicies
	inline public static var A           :Int = 65;
	inline public static var B           :Int = 66;
	inline public static var C           :Int = 67;
	inline public static var D           :Int = 68;
	inline public static var E           :Int = 69;
	inline public static var F           :Int = 70;
	inline public static var G           :Int = 71;
	inline public static var H           :Int = 72;
	inline public static var I           :Int = 73;
	inline public static var J           :Int = 74;
	inline public static var K           :Int = 75;
	inline public static var L           :Int = 76;
	inline public static var M           :Int = 77;
	inline public static var N           :Int = 78;
	inline public static var O           :Int = 79;
	inline public static var P           :Int = 80;
	inline public static var Q           :Int = 81;
	inline public static var R           :Int = 82;
	inline public static var S           :Int = 83;
	inline public static var T           :Int = 84;
	inline public static var U           :Int = 85;
	inline public static var V           :Int = 86;
	inline public static var W           :Int = 87;
	inline public static var X           :Int = 88;
	inline public static var Y           :Int = 89;
	inline public static var Z           :Int = 90;
	inline public static var ZERO        :Int = 48;
	inline public static var ONE         :Int = 49;
	inline public static var TWO         :Int = 50;
	inline public static var THREE       :Int = 51;
	inline public static var FOUR        :Int = 52;
	inline public static var FIVE        :Int = 53;
	inline public static var SIX         :Int = 54;
	inline public static var SEVEN       :Int = 55;
	inline public static var EIGHT       :Int = 56;
	inline public static var NINE        :Int = 57;
	inline public static var PAGEUP      :Int = 33;
	inline public static var PAGEDOWN    :Int = 34;
	inline public static var HOME        :Int = 36;
	inline public static var END         :Int = 35;
	inline public static var INSERT      :Int = 45;
	inline public static var ESCAPE      :Int = 27;
	inline public static var MINUS       :Int = 189;
	inline public static var PLUS        :Int = 187;
	inline public static var DELETE      :Int = 46;
	inline public static var BACKSPACE   :Int = 8;
	inline public static var LBRACKET    :Int = 219;
	inline public static var RBRACKET    :Int = 221;
	inline public static var BACKSLASH   :Int = 220;
	inline public static var CAPSLOCK    :Int = 20;
	inline public static var SEMICOLON   :Int = 186;
	inline public static var QUOTE       :Int = 222;
	inline public static var ENTER       :Int = 13;
	inline public static var SHIFT       :Int = 16;
	inline public static var COMMA       :Int = 188;
	inline public static var PERIOD      :Int = 190;
	inline public static var SLASH       :Int = 191;
	inline public static var NUMPADSLASH :Int = 191;
	inline public static var GRAVEACCENT :Int = 192;
	inline public static var CONTROL     :Int = 17;
	inline public static var ALT         :Int = 18;
	inline public static var SPACE       :Int = 32;
	inline public static var UP          :Int = 38;
	inline public static var DOWN        :Int = 40;
	inline public static var LEFT        :Int = 37;
	inline public static var RIGHT       :Int = 39;
	inline public static var TAB         :Int = 9;
#if (flash || js)
	inline public static var F1          :Int = 112;
	inline public static var F2          :Int = 113;
	inline public static var F3          :Int = 114;
	inline public static var F4          :Int = 115;
	inline public static var F5          :Int = 116;
	inline public static var F6          :Int = 117;
	inline public static var F7          :Int = 118;
	inline public static var F8          :Int = 119;
	inline public static var F9          :Int = 120;
	inline public static var F10         :Int = 121;
	inline public static var F11         :Int = 122;
	inline public static var F12         :Int = 123;
	inline public static var NUMPADZERO  :Int = 96;
	inline public static var NUMPADONE   :Int = 97;
	inline public static var NUMPADTWO   :Int = 98;
	inline public static var NUMPADTHREE :Int = 99;
	inline public static var NUMPADFOUR  :Int = 100;
	inline public static var NUMPADFIVE  :Int = 101;
	inline public static var NUMPADSIX   :Int = 102;
	inline public static var NUMPADSEVEN :Int = 103;
	inline public static var NUMPADEIGHT :Int = 104;
	inline public static var NUMPADNINE  :Int = 105;
	inline public static var NUMPADMINUS :Int = 109;
	inline public static var NUMPADPLUS  :Int = 107;
	inline public static var NUMPADPERIOD:Int = 110;
#end
	
	/**
	 * The name of this key.
	 */
	public var name:String;
	/**
	 * The current state of this key.
	 */
	public var current:Int = RELEASED;
	/**
	 * The last state of this key.
	 */
	public var last:Int = RELEASED;
	
	public function new(Name:String)
	{
		name = Name;
	}
}