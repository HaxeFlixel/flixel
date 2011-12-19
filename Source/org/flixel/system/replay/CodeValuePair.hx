package org.flixel.system.replay;

/**
 * ...
 * @author Zaphod
 */

class CodeValuePair
{
	public var code:Int;
	public var value:Int;
	
	public function new(code:Int = 0, value:Int = 0)
	{
		this.code = code;
		this.value = value;
	}
	
	public static function convertFromFlashToCpp(pair:CodeValuePair):CodeValuePair
	{
		var convertedCode:Int = 0;
		switch (pair.code)
		{
			case 65: // A
				convertedCode = 97;
			case 66: // B
				convertedCode = 98;
			case 67: // C
				convertedCode = 99;
			case 68: // D
				convertedCode = 100;
			case 69: // E
				convertedCode = 101;
			case 70: // F
				convertedCode = 102;
			case 71: // G
				convertedCode = 103;
			case 72: // H
				convertedCode = 104;
			case 73: // I
				convertedCode = 105;
			case 74: // J
				convertedCode = 106;
			case 75: // K
				convertedCode = 107;
			case 76: // L
				convertedCode = 108;
			case 77: // M
				convertedCode = 109;
			case 78: // N
				convertedCode = 110;
			case 79: // O
				convertedCode = 111;
			case 80: // P
				convertedCode = 112;
			case 81: // Q
				convertedCode = 113;
			case 82: // R
				convertedCode = 114;
			case 83: // S
				convertedCode = 115;
			case 84: // T
				convertedCode = 116;
			case 85: // U
				convertedCode = 117;
			case 86: // V
				convertedCode = 118;
			case 87: // W
				convertedCode = 119;
			case 88: // X
				convertedCode = 120;
			case 89: // Y
				convertedCode = 121;
			case 90: // Z
				convertedCode = 122;
			default:
				convertedCode = pair.code;
		}
		pair.code = convertedCode;
		return pair;
	}
	
}