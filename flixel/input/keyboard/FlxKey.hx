package flixel.input.keyboard;

/**
 * A helper class for keyboard input.
 */
class FlxKey
{
	// Key States
	inline static public var JUST_RELEASED:Int = -1;
	inline static public var RELEASED     :Int =  0;
	inline static public var PRESSED      :Int =  1;
	inline static public var JUST_PRESSED :Int =  2;
	
	// Key Indicies
	inline static public var A           :Int = 65;
	inline static public var B           :Int = 66;
	inline static public var C           :Int = 67;
	inline static public var D           :Int = 68;
	inline static public var E           :Int = 69;
	inline static public var F           :Int = 70;
	inline static public var G           :Int = 71;
	inline static public var H           :Int = 72;
	inline static public var I           :Int = 73;
	inline static public var J           :Int = 74;
	inline static public var K           :Int = 75;
	inline static public var L           :Int = 76;
	inline static public var M           :Int = 77;
	inline static public var N           :Int = 78;
	inline static public var O           :Int = 79;
	inline static public var P           :Int = 80;
	inline static public var Q           :Int = 81;
	inline static public var R           :Int = 82;
	inline static public var S           :Int = 83;
	inline static public var T           :Int = 84;
	inline static public var U           :Int = 85;
	inline static public var V           :Int = 86;
	inline static public var W           :Int = 87;
	inline static public var X           :Int = 88;
	inline static public var Y           :Int = 89;
	inline static public var Z           :Int = 90;
	inline static public var ZERO        :Int = 48;
	inline static public var ONE         :Int = 49;
	inline static public var TWO         :Int = 50;
	inline static public var THREE       :Int = 51;
	inline static public var FOUR        :Int = 52;
	inline static public var FIVE        :Int = 53;
	inline static public var SIX         :Int = 54;
	inline static public var SEVEN       :Int = 55;
	inline static public var EIGHT       :Int = 56;
	inline static public var NINE        :Int = 57;
	inline static public var PAGEUP      :Int = 33;
	inline static public var PAGEDOWN    :Int = 34;
	inline static public var HOME        :Int = 36;
	inline static public var END         :Int = 35;
	inline static public var INSERT      :Int = 45;
	inline static public var ESCAPE      :Int = 27;
	inline static public var MINUS       :Int = 189;
	inline static public var PLUS        :Int = 187;
	inline static public var DELETE      :Int = 46;
	inline static public var BACKSPACE   :Int = 8;
	inline static public var LBRACKET    :Int = 219;
	inline static public var RBRACKET    :Int = 221;
	inline static public var BACKSLASH   :Int = 220;
	inline static public var CAPSLOCK    :Int = 20;
	inline static public var SEMICOLON   :Int = 186;
	inline static public var QUOTE       :Int = 222;
	inline static public var ENTER       :Int = 13;
	inline static public var SHIFT       :Int = 16;
	inline static public var COMMA       :Int = 188;
	inline static public var PERIOD      :Int = 190;
	inline static public var SLASH       :Int = 191;
	inline static public var NUMPADSLASH :Int = 191;
	inline static public var GRAVEACCENT :Int = 192;
	inline static public var CONTROL     :Int = 17;
	inline static public var ALT         :Int = 18;
	inline static public var SPACE       :Int = 32;
	inline static public var UP          :Int = 38;
	inline static public var DOWN        :Int = 40;
	inline static public var LEFT        :Int = 37;
	inline static public var RIGHT       :Int = 39;
	inline static public var TAB         :Int = 9;
#if (flash || js)
	inline static public var F1          :Int = 112;
	inline static public var F2          :Int = 113;
	inline static public var F3          :Int = 114;
	inline static public var F4          :Int = 115;
	inline static public var F5          :Int = 116;
	inline static public var F6          :Int = 117;
	inline static public var F7          :Int = 118;
	inline static public var F8          :Int = 119;
	inline static public var F9          :Int = 120;
	inline static public var F10         :Int = 121;
	inline static public var F11         :Int = 122;
	inline static public var F12         :Int = 123;
	inline static public var NUMPADZERO  :Int = 96;
	inline static public var NUMPADONE   :Int = 97;
	inline static public var NUMPADTWO   :Int = 98;
	inline static public var NUMPADTHREE :Int = 99;
	inline static public var NUMPADFOUR  :Int = 100;
	inline static public var NUMPADFIVE  :Int = 101;
	inline static public var NUMPADSIX   :Int = 102;
	inline static public var NUMPADSEVEN :Int = 103;
	inline static public var NUMPADEIGHT :Int = 104;
	inline static public var NUMPADNINE  :Int = 105;
	inline static public var NUMPADMINUS :Int = 109;
	inline static public var NUMPADPLUS  :Int = 107;
	inline static public var NUMPADPERIOD:Int = 110;
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