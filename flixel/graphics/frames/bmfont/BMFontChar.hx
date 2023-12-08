package flixel.graphics.frames.bmfont;

import haxe.io.BytesInput;
import haxe.xml.Access;
import UnicodeString;

using StringTools;

/**
 * Bitmap font character data used internally via `FlxBitmapFont.fromAngelCode` to serialize text,
 * xml or binary files exported from [BMFont](https://www.angelcode.com/products/bmfont/)
 * 
 * @since 5.6.0
 * @see [flixel.graphics.frames.FlxBitmapFont.fromAngelCode](https://api.haxeflixel.com/flixel/graphics/frames/FlxBitmapFont.html#fromAngelCode)
 */
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
		return {
			id: Std.parseInt(charNode.att.id),
			x: Std.parseInt(charNode.att.x),
			y: Std.parseInt(charNode.att.y),
			width: Std.parseInt(charNode.att.width),
			height: Std.parseInt(charNode.att.height),
			xoffset: (charNode.has.xoffset) ? Std.parseInt(charNode.att.xoffset) : 0,
			yoffset: (charNode.has.yoffset) ? Std.parseInt(charNode.att.yoffset) : 0,
			xadvance: (charNode.has.xadvance) ? Std.parseInt(charNode.att.xadvance) : 0,
			page: Std.parseInt(charNode.att.page),
			chnl: Std.parseInt(charNode.att.chnl),
			letter: charNode.has.letter ? charNode.att.letter : null
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