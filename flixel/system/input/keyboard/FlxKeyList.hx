package flixel.system.input.keyboard;
import flixel.FlxG;

/**
 * A helper class for keyboard input.
 */
class FlxKeyList
{
	public function new(CheckFunction:String->Bool)
	{
		check = CheckFunction;
	}
	
	private var check:String->Bool;
	
	public var ESCAPE		(get, never):Bool;	inline function get_ESCAPE()		{ return check("ESCAPE"); 		}
	public var F1			(get, never):Bool;	inline function get_F1()			{ return check("F1"); 			}
	public var F2			(get, never):Bool;	inline function get_F2()			{ return check("F2"); 			}
	public var F3			(get, never):Bool;	inline function get_F3()			{ return check("F3"); 			}
	public var F4			(get, never):Bool;	inline function get_F4()			{ return check("F4"); 			}
	public var F5			(get, never):Bool;	inline function get_F5()			{ return check("F5"); 			}
	public var F6			(get, never):Bool;	inline function get_F6()			{ return check("F6"); 			}
	public var F7			(get, never):Bool;	inline function get_F7()			{ return check("F7"); 			}
	public var F8			(get, never):Bool;	inline function get_F8()			{ return check("F8"); 			}
	public var F9			(get, never):Bool;	inline function get_F9()			{ return check("F9"); 			}
	public var F10			(get, never):Bool;	inline function get_F10()			{ return check("F10"); 			}
	public var F11			(get, never):Bool;	inline function get_F11()			{ return check("F11"); 			}
	public var F12			(get, never):Bool;	inline function get_F12()			{ return check("F12"); 			}
	public var ONE			(get, never):Bool;	inline function get_ONE()			{ return check("ONE"); 			}
	public var TWO			(get, never):Bool;	inline function get_TWO()			{ return check("TWO"); 			}
	public var THREE		(get, never):Bool;	inline function get_THREE()			{ return check("THREE"); 		}
	public var FOUR			(get, never):Bool;	inline function get_FOUR()			{ return check("FOUR"); 		}
	public var FIVE			(get, never):Bool;	inline function get_FIVE()			{ return check("FIVE");			}
	public var SIX			(get, never):Bool;	inline function get_SIX()			{ return check("SIX"); 			}
	public var SEVEN		(get, never):Bool;	inline function get_SEVEN()			{ return check("SEVEN"); 		}
	public var EIGHT		(get, never):Bool;	inline function get_EIGHT()			{ return check("EIGHT"); 		}
	public var NINE			(get, never):Bool;	inline function get_NINE()			{ return check("NINE"); 		}
	public var ZERO			(get, never):Bool;	inline function get_ZERO()			{ return check("ZERO"); 		}
	public var NUMPADONE	(get, never):Bool;	inline function get_NUMPADONE()		{ return check("NUMPADONE"); 	}
	public var NUMPADTWO	(get, never):Bool;	inline function get_NUMPADTWO()		{ return check("NUMPADTWO"); 	}
	public var NUMPADTHREE	(get, never):Bool;	inline function get_NUMPADTHREE()	{ return check("NUMPADTHREE"); 	}
	public var NUMPADFOUR	(get, never):Bool;	inline function get_NUMPADFOUR()	{ return check("NUMPADFOUR"); 	}
	public var NUMPADFIVE	(get, never):Bool;	inline function get_NUMPADFIVE()	{ return check("NUMPADFIVE"); 	}
	public var NUMPADSIX	(get, never):Bool;	inline function get_NUMPADSIX()		{ return check("NUMPADSIX"); 	}
	public var NUMPADSEVEN	(get, never):Bool;	inline function get_NUMPADSEVEN()	{ return check("NUMPADSEVEN"); 	}
	public var NUMPADEIGHT	(get, never):Bool;	inline function get_NUMPADEIGHT()	{ return check("NUMPADEIGHT"); 	}
	public var NUMPADNINE	(get, never):Bool;	inline function get_NUMPADNINE()	{ return check("NUMPADNINE"); 	}
	public var NUMPADZERO	(get, never):Bool;	inline function get_NUMPADZERO()	{ return check("NUMPADZERO"); 	}
	public var PAGEUP		(get, never):Bool;	inline function get_PAGEUP()		{ return check("PAGEUP"); 		}	
	public var PAGEDOWN		(get, never):Bool;	inline function get_PAGEDOWN()		{ return check("PAGEDOWN"); 	}
	public var HOME			(get, never):Bool;	inline function get_HOME()			{ return check("HOME"); 		}
	public var END			(get, never):Bool;	inline function get_END()			{ return check("END"); 			}
	public var INSERT		(get, never):Bool;	inline function get_INSERT()		{ return check("INSERT"); 		}
	public var MINUS		(get, never):Bool;	inline function get_MINUS()			{ return check("MINUS"); 		}
	public var NUMPADMINUS	(get, never):Bool;	inline function get_NUMPADMINUS()	{ return check("NUMPADMINUS"); 	}
	public var PLUS			(get, never):Bool;	inline function get_PLUS()			{ return check("PLUS"); 		}
	public var NUMPADPLUS	(get, never):Bool;	inline function get_NUMPADPLUS()	{ return check("NUMPADPLUS"); 	}
	public var DELETE		(get, never):Bool;	inline function get_DELETE()		{ return check("DELETE"); 		}
	public var BACKSPACE	(get, never):Bool;	inline function get_BACKSPACE()		{ return check("BACKSPACE"); 	}
	public var TAB			(get, never):Bool;	inline function get_TAB()			{ return check("TAB"); 			}
	public var Q			(get, never):Bool;	inline function get_Q()				{ return check("Q"); 			}
	public var W			(get, never):Bool;	inline function get_W()				{ return check("W"); 			}
	public var E			(get, never):Bool;	inline function get_E()				{ return check("E"); 			}
	public var R			(get, never):Bool;	inline function get_R()				{ return check("R"); 			}
	public var T			(get, never):Bool;	inline function get_T()				{ return check("T"); 			}
	public var Y			(get, never):Bool;	inline function get_Y()				{ return check("Y"); 			}
	public var U			(get, never):Bool;	inline function get_U()				{ return check("U"); 			}
	public var I			(get, never):Bool;	inline function get_I()				{ return check("I"); 			}
	public var O			(get, never):Bool;	inline function get_O()				{ return check("O"); 			}
	public var P			(get, never):Bool;	inline function get_P()				{ return check("P"); 			}
	public var LBRACKET		(get, never):Bool;	inline function get_LBRACKET()		{ return check("LBRACKET"); 	}
	public var RBRACKET		(get, never):Bool;	inline function get_RBRACKET()		{ return check("RBRACKET"); 	}
	public var BACKSLASH	(get, never):Bool;	inline function get_BACKSLASH()		{ return check("BACKSLASH"); 	}
	public var CAPSLOCK		(get, never):Bool;	inline function get_CAPSLOCK()		{ return check("CAPSLOCK"); 	}
	public var A			(get, never):Bool;	inline function get_A()				{ return check("A"); 			}
	public var S			(get, never):Bool;	inline function get_S()				{ return check("S"); 			}
	public var D			(get, never):Bool;	inline function get_D()				{ return check("D"); 			}
	public var F			(get, never):Bool;	inline function get_F()				{ return check("F"); 			}
	public var G			(get, never):Bool;	inline function get_G()				{ return check("G"); 			}
	public var H			(get, never):Bool;	inline function get_H()				{ return check("H"); 			}
	public var J			(get, never):Bool;	inline function get_J()				{ return check("J"); 			}
	public var K			(get, never):Bool;	inline function get_K()				{ return check("K"); 			}
	public var L			(get, never):Bool;	inline function get_L()				{ return check("L"); 			}
	public var SEMICOLON	(get, never):Bool;	inline function get_SEMICOLON()		{ return check("SEMICOLON"); 	}
	public var QUOTE		(get, never):Bool;	inline function get_QUOTE()			{ return check("QUOTE"); 		}
	public var ENTER		(get, never):Bool;	inline function get_ENTER()			{ return check("ENTER"); 		}
	public var SHIFT		(get, never):Bool;	inline function get_SHIFT()			{ return check("SHIFT"); 		}
	public var Z			(get, never):Bool;	inline function get_Z()				{ return check("Z"); 			}
	public var X			(get, never):Bool;	inline function get_X()				{ return check("X"); 			}
	public var C			(get, never):Bool;	inline function get_C()				{ return check("C"); 			}
	public var V			(get, never):Bool;	inline function get_V()				{ return check("V"); 			}
	public var B			(get, never):Bool;	inline function get_B()				{ return check("B"); 			}
	public var N			(get, never):Bool;	inline function get_N()				{ return check("N"); 			}
	public var M			(get, never):Bool;	inline function get_M()				{ return check("M"); 			}
	public var COMMA		(get, never):Bool;	inline function get_COMMA()			{ return check("COMMA"); 		}
	public var PERIOD		(get, never):Bool;	inline function get_PERIOD()		{ return check("PERIOD"); 		}
	public var NUMPADPERIOD	(get, never):Bool;	inline function get_NUMPADPERIOD()	{ return check("NUMPADPERIOD"); }
	public var SLASH		(get, never):Bool;	inline function get_SLASH()			{ return check("SLASH"); 		}
	public var NUMPADSLASH	(get, never):Bool;	inline function get_NUMPADSLASH()	{ return check("NUMPADSLASH"); 	}
	public var CONTROL		(get, never):Bool;	inline function get_CONTROL()		{ return check("CONTROL"); 		}
	public var ALT			(get, never):Bool;	inline function get_ALT()			{ return check("ALT"); 			}
	public var SPACE		(get, never):Bool;	inline function get_SPACE()			{ return check("SPACE"); 		}
	public var UP			(get, never):Bool;	inline function get_UP()			{ return check("UP"); 			}
	public var DOWN			(get, never):Bool;	inline function get_DOWN()			{ return check("DOWN"); 		}
	public var LEFT			(get, never):Bool;	inline function get_LEFT()			{ return check("LEFT"); 		}
	public var RIGHT		(get, never):Bool;	inline function get_RIGHT()			{ return check("RIGHT"); 		}
	
	public var ANY(get, never):Bool; 
	
	// So we can get access to _keyList
	@:access(flixel.system.input.keyboard.FlxKeyboard._keyList)
	private function get_ANY():Bool			
	{ 
		for (key in FlxG.keyboard._keyList)
		{
			if (key != null)
			{
				if (check(key.name))
				{
					return true;
				}
			}
		}
		
		return false;
	}
}