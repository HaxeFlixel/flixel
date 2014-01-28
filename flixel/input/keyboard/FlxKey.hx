package flixel.input.keyboard;

/**
 * A helper class for keyboard input.
 */
class FlxKey
{
	// Key States
	public inline static var JUST_RELEASED:Int = -1;
	public inline static var RELEASED     :Int =  0;
	public inline static var PRESSED      :Int =  1;
	public inline static var JUST_PRESSED :Int =  2;
	
	// Key Indicies
	public inline static var A           :Int = 65;
	public inline static var B           :Int = 66;
	public inline static var C           :Int = 67;
	public inline static var D           :Int = 68;
	public inline static var E           :Int = 69;
	public inline static var F           :Int = 70;
	public inline static var G           :Int = 71;
	public inline static var H           :Int = 72;
	public inline static var I           :Int = 73;
	public inline static var J           :Int = 74;
	public inline static var K           :Int = 75;
	public inline static var L           :Int = 76;
	public inline static var M           :Int = 77;
	public inline static var N           :Int = 78;
	public inline static var O           :Int = 79;
	public inline static var P           :Int = 80;
	public inline static var Q           :Int = 81;
	public inline static var R           :Int = 82;
	public inline static var S           :Int = 83;
	public inline static var T           :Int = 84;
	public inline static var U           :Int = 85;
	public inline static var V           :Int = 86;
	public inline static var W           :Int = 87;
	public inline static var X           :Int = 88;
	public inline static var Y           :Int = 89;
	public inline static var Z           :Int = 90;
	public inline static var ZERO        :Int = 48;
	public inline static var ONE         :Int = 49;
	public inline static var TWO         :Int = 50;
	public inline static var THREE       :Int = 51;
	public inline static var FOUR        :Int = 52;
	public inline static var FIVE        :Int = 53;
	public inline static var SIX         :Int = 54;
	public inline static var SEVEN       :Int = 55;
	public inline static var EIGHT       :Int = 56;
	public inline static var NINE        :Int = 57;
	public inline static var PAGEUP      :Int = 33;
	public inline static var PAGEDOWN    :Int = 34;
	public inline static var HOME        :Int = 36;
	public inline static var END         :Int = 35;
	public inline static var INSERT      :Int = 45;
	public inline static var ESCAPE      :Int = 27;
	public inline static var MINUS       :Int = 189;
	public inline static var PLUS        :Int = 187;
	public inline static var DELETE      :Int = 46;
	public inline static var BACKSPACE   :Int = 8;
	public inline static var LBRACKET    :Int = 219;
	public inline static var RBRACKET    :Int = 221;
	public inline static var BACKSLASH   :Int = 220;
	public inline static var CAPSLOCK    :Int = 20;
	public inline static var SEMICOLON   :Int = 186;
	public inline static var QUOTE       :Int = 222;
	public inline static var ENTER       :Int = 13;
	public inline static var SHIFT       :Int = 16;
	public inline static var COMMA       :Int = 188;
	public inline static var PERIOD      :Int = 190;
	public inline static var SLASH       :Int = 191;
	public inline static var NUMPADSLASH :Int = 191;
	public inline static var GRAVEACCENT :Int = 192;
	public inline static var CONTROL     :Int = 17;
	public inline static var ALT         :Int = 18;
	public inline static var SPACE       :Int = 32;
	public inline static var UP          :Int = 38;
	public inline static var DOWN        :Int = 40;
	public inline static var LEFT        :Int = 37;
	public inline static var RIGHT       :Int = 39;
	public inline static var TAB         :Int = 9;
#if (flash || js)
	public inline static var F1          :Int = 112;
	public inline static var F2          :Int = 113;
	public inline static var F3          :Int = 114;
	public inline static var F4          :Int = 115;
	public inline static var F5          :Int = 116;
	public inline static var F6          :Int = 117;
	public inline static var F7          :Int = 118;
	public inline static var F8          :Int = 119;
	public inline static var F9          :Int = 120;
	public inline static var F10         :Int = 121;
	public inline static var F11         :Int = 122;
	public inline static var F12         :Int = 123;
	public inline static var NUMPADZERO  :Int = 96;
	public inline static var NUMPADONE   :Int = 97;
	public inline static var NUMPADTWO   :Int = 98;
	public inline static var NUMPADTHREE :Int = 99;
	public inline static var NUMPADFOUR  :Int = 100;
	public inline static var NUMPADFIVE  :Int = 101;
	public inline static var NUMPADSIX   :Int = 102;
	public inline static var NUMPADSEVEN :Int = 103;
	public inline static var NUMPADEIGHT :Int = 104;
	public inline static var NUMPADNINE  :Int = 105;
	public inline static var NUMPADMINUS :Int = 109;
	public inline static var NUMPADPLUS  :Int = 107;
	public inline static var NUMPADPERIOD:Int = 110;
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