package flixel.graphics.frames.bmfont;

import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import openfl.utils.Assets;

using StringTools;

/**
 * Used internally via `FlxBitmapFont.fromAngelCode` to serialize text, xml or binary files
 * exported from [BMFont](https://www.angelcode.com/products/bmfont/)
 * 
 * @since 5.6.0
 * @see [flixel.graphics.frames.FlxBitmapFont.fromAngelCode](https://api.haxeflixel.com/flixel/graphics/frames/FlxBitmapFont.html#fromAngelCode)
 */
class BMFont
{
	public var info:BMFontInfo;
	public var common:BMFontCommon;
	public var pages:Array<BMFontPage>;
	public var chars:Array<BMFontChar>;
	public var kernings:Null<Array<BMFontKerning>> = null;
	
	function new(?info, ?common, ?pages, ?chars, ?kernings)
	{
		this.info = info;
		this.common = common;
		this.pages = pages;
		this.chars = chars;
		this.kernings = kernings;
	}
	
	public static function fromXml(xml:Xml)
	{
		final main = new BMFontXml(xml);
		final info = BMFontInfo.fromXml(main.node.get("info"));
		final common = BMFontCommon.fromXml(main.node.get("common"));
		final pages = BMFontPage.listFromXml(main.node.get("pages"));
		final chars = BMFontChar.listFromXml(main.node.get("chars"));
		var kernings:Array<BMFontKerning> = null;
		
		if (main.hasNode("kernings"))
		{
			kernings = BMFontKerning.listFromXml(main.node.get("kernings"));
		}
		
		return new BMFont(info, common, pages, chars, kernings);
	}
	
	public static function fromText(text:String)
	{
		var info:BMFontInfo = null;
		var common:BMFontCommon = null;
		final pages = new Array<BMFontPage>();
		final chars = new Array<BMFontChar>();
		final kernings = new Array<BMFontKerning>();
		// we dont need these but they exists in the file
		// var charCount = 0;
		// var kerningCount = 0;
		
		final lines = text.replace('\r\n', '\n').split('\n').filter((line) -> line.length > 0);
		for (line in lines)
		{
			final blockType = line.substring(0, line.indexOf(' '));
			final blockAttrs = line.substring(line.indexOf(' ') + 1);
			switch blockType
			{
				case 'info': info = BMFontInfo.fromText(blockAttrs);
				case 'common': common = BMFontCommon.fromText(blockAttrs);
				case 'page': pages.push(BMFontPage.fromText(blockAttrs));
				// case 'chars': charCount = Std.parseInt(blockAttrs.split("=").pop());
				case 'char': chars.push(BMFontChar.fromText(blockAttrs));
				// case 'kernings': kerningCount = Std.parseInt(blockAttrs.split("=").pop());
				case 'kerning': kernings.push(BMFontKerning.fromText(blockAttrs));
			}
		}
		
		return new BMFont(info, common, pages, chars, kernings.length > 0 ? kernings : null);
	}
	
	/**
	 * @see https://www.angelcode.com/products/bmfont/doc/file_format.html#bin
	 */
	public static function fromBytes(bytes:Bytes)
	{
		final bytes = new BytesInput(bytes);
		final expectedBytes = [66, 77, 70]; // 'B', 'M', 'F'
		for (b in expectedBytes)
		{
			var testByte = bytes.readByte();
			if (testByte != b)
				throw 'Invalid binary .fnt file. Found $testByte, expected $b';
		}
		var version = bytes.readByte();
		if (version < 3)
		{
			FlxG.log.warn('The BMFont parser is made to work on files with version 3. Using earlier versions can cause issues!');
		}
		
		var info:BMFontInfo = null;
		var common:BMFontCommon = null;
		var pages:Array<BMFontPage> = null;
		var chars:Array<BMFontChar> = null;
		var kerning:Array<BMFontKerning> = null;
		
		// parsing blocks
		while (bytes.position < bytes.length)
		{
			final blockId:BMFontBlockId = bytes.readByte();
			switch blockId
			{
				case INFO: info = BMFontInfo.fromBytes(bytes);
				case COMMON: common = BMFontCommon.fromBytes(bytes);
				case PAGES: pages = BMFontPage.listFromBytes(bytes);
				case CHARS: chars = BMFontChar.listFromBytes(bytes);
				case KERNING: kerning = BMFontKerning.listFromBytes(bytes);
			}
		}
		return new BMFont(info, common, pages, chars, kerning);
	}
	
	@:access(flixel.graphics.frames.FlxBitmapFont)
	public function initBitmapFont(font:FlxBitmapFont):FlxBitmapFont
	{
		// how much to move the cursor when going to the next line.
		font.lineHeight = common.lineHeight;
		font.size = info.size;
		font.fontName = info.face;
		font.bold = info.bold;
		font.italic = info.italic;
		
		for (char in chars)
		{
			final frame = FlxRect.get();
			frame.x = char.x; // X position within the bitmap image file.
			frame.y = char.y; // Y position within the bitmap image file.
			frame.width = char.width; // Width of the character in the image file.
			frame.height = char.height; // Height of the character in the image file.
			
			font.minOffsetX = (font.minOffsetX < -char.xoffset) ? -char.xoffset : font.minOffsetX;
			
			if (char.id == -1)
			{
				throw 'Invalid font data!';
			}
			
			font.addCharFrame(char.id, frame, FlxPoint.get(char.xoffset, char.yoffset), char.xadvance);
			
			if (char.id == FlxBitmapFont.SPACE_CODE)
			{
				font.spaceWidth = char.xadvance;
			}
			else
			{
				font.lineHeight = (font.lineHeight > char.height + char.yoffset) ? font.lineHeight : char.height + char.yoffset;
			}
		}
		
		if (kernings != null)
		{
			for (kerning in kernings)
				font.addKerningPair(kerning.first, kerning.second, kerning.amount);
		}
		
		font.updateSourceHeight();
		return font;
	}
	
	public static function parse(data:FlxAngelCodeAsset):BMFont
	{
		return switch guessType(data)
		{
			case TEXT(text): fromText(text);
			case XML(xml): fromXml(xml);
			case BINARY(bytes): fromBytes(bytes);
		};
	}
	
	/**
	 * A helper function that helps determine the type of BMFont descriptor from either the path or content of the file
	 * @param data The file path or the file content
	 * @return BMFontFileType
	 */
	static function guessType(data:FlxAngelCodeAsset):BMFontFileType
	{
		if (data is Xml)
		{
			return XML(cast(data, Xml).firstElement());
		}
		
		if (data is Bytes)
		{
			final bytes:Bytes = cast data;
			if (isValidBytes(bytes))
				return BINARY(bytes);
			
			return detectFromText(bytes.toString());
		}
		
		if (data is String)
		{
			final dataStr:String = cast data;
			if (Assets.exists(dataStr))
			{
				// dataStr is a file path
				final bytes = Assets.getBytes(dataStr);
				if(bytes == null)
					return detectFromText(Assets.getText(dataStr));
				
				if (isValidBytes(bytes))
					return BINARY(bytes);
				
				return detectFromText(bytes.toString());
			}
			else
			{
				// dataStr is the content of a file as a string (can be xml or just plain text)
				return detectFromText(dataStr);
			}
		}
		
		throw 'Invalid FlxAngelCodeAsset: $data';
	}
	
	static function safeParseXML(str:String)
	{
		// for js, Xml.parse throws if str is not valid XML but on desktop it just returns null
		// This function will always return null if xml is invalid
		try
		{
			var xml = Xml.parse(str);
			return xml;
		}
		catch (e:Dynamic)
		{
			return null;
		}
	}

	static function detectFromText(text:String):BMFontFileType
	{
		final xml = safeParseXML(text);
		if (xml != null && xml.firstElement() != null)
		{
			return XML(xml.firstElement());
		}
		return TEXT(text);
	}
	
	static function isValidBytes(bytes:Bytes)
	{
		final expected = [66, 77, 70]; // 'B', 'M', 'F'
		for (i in 0...expected.length)
		{
			if (bytes.get(i) != expected[i])
				return false;
		}
		
		return true;
	}
}

private enum abstract BMFontBlockId(Int) from Int
{
	var INFO = 1;
	var COMMON = 2;
	var PAGES = 3;
	var CHARS = 4;
	var KERNING = 5;
}

private enum BMFontFileType
{
	TEXT(text:String);
	XML(xml:Xml);
	BINARY(bytes:Bytes);
}