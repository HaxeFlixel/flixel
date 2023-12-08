package flixel.graphics.frames.bmfont;

import haxe.io.BytesInput;
import haxe.xml.Access;
import UnicodeString;

using StringTools;

@:structInit
@:allow(flixel.graphics.frames.bmfont.BMFont)
class BMFontChar
{
	public var id:Int;
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var xoffset:Int;
	public var yoffset:Int;
	public var xadvance:Int;
	public var page:Int;
	public var chnl:Int;
	public var letter:Null<String> = null;
	
	static inline function fromXml(charNode:Access):BMFontChar
	{
		final char = charNode;
		
		final letter = char.has.letter ? char.att.letter : null;
		final id = Std.parseInt(char.att.id);
		return {
			id: (letter != null) ? getCorrectLetter(letter).charCodeAt(0) : id,
			x: Std.parseInt(char.att.x),
			y: Std.parseInt(char.att.y),
			width: Std.parseInt(char.att.width),
			height: Std.parseInt(char.att.height),
			xoffset: (char.has.xoffset) ? Std.parseInt(char.att.xoffset) : 0,
			yoffset: (char.has.yoffset) ? Std.parseInt(char.att.yoffset) : 0,
			xadvance: (char.has.xadvance) ? Std.parseInt(char.att.xadvance) : 0,
			page: Std.parseInt(char.att.page),
			chnl: Std.parseInt(char.att.chnl),
			letter: letter
		};
	}
	
	static function listFromXml(charsNode:Access):Array<BMFontChar>
	{
		final chars = charsNode.nodes.char;
		return [ for (char in chars) fromXml(char) ];
	}
	
	static function fromText(kerningText:String):BMFontChar
	{
		var id:Int = -1;
		var x:Int = -1;
		var y:Int = -1;
		var width:Int = 0;
		var height:Int = 0;
		var xoffset:Int = 0;
		var yoffset:Int = 0;
		var xadvance:Int = 0;
		var page:Int = -1;
		var chnl:Int = -1;
		var letter:String = null;
		
		BMFontUtil.forEachAttribute(kerningText, 
			function(key:String, value:UnicodeString)
			{
				switch key
				{
					case 'id': id = Std.parseInt(value);
					case 'x': x = Std.parseInt(value);
					case 'y': y = Std.parseInt(value);
					case 'width': width = Std.parseInt(value);
					case 'height': height = Std.parseInt(value);
					case 'xoffset': xoffset = Std.parseInt(value);
					case 'yoffset': yoffset = Std.parseInt(value);
					case 'xadvance': xadvance = Std.parseInt(value);
					case 'page': page = Std.parseInt(value);
					case 'chnl': chnl = Std.parseInt(value);
					case 'letter': letter = value;
					default: FlxG.log.warn('Unexpected font char attribute: $key=$value');
				}
			}
		);
		
		if (letter != null)
			id = getCorrectLetter(letter).charCodeAt(0);
		
		return
		{
			id: id,
			x: x,
			y: y,
			width: width,
			height: height,
			xoffset: xoffset,
			yoffset: yoffset,
			xadvance: xadvance,
			page: page,
			chnl: chnl,
			letter: letter
		};
	}
	
	static function listFromBytes(bytes:BytesInput):Array<BMFontChar>
	{
		var blockSize = bytes.readInt32();
		final chars = new Array<BMFontChar>();
		while (blockSize > 0)
		{
			final char:BMFontChar = {
				id: bytes.readInt32(),
				x: bytes.readInt16(),
				y: bytes.readInt16(),
				width: bytes.readInt16(),
				height: bytes.readInt16(),
				xoffset: bytes.readInt16(),
				yoffset: bytes.readInt16(),
				xadvance: bytes.readInt16(),
				page: bytes.readByte(),
				chnl: bytes.readByte()
			};
			chars.push(char);
			blockSize -= 20;
		}
		return chars;
	}
	
	static function getCorrectLetter(letter:String)
	{
		// handle some special cases of letters in the xml files
		return switch (letter)
		{
			case "space": ' ';
			case "&quot;": '"';
			case "&amp;": '&';
			case "&gt;": '>';
			case "&lt;": '<';
			default: letter;
		}
	}
}