package flixel.graphics.frames.bmfontutils;

import flixel.system.FlxAssets.FlxAngelCodeXmlAsset;
import flixel.util.typeLimit.OneOfTwo;
import haxe.io.Bytes;
import openfl.Assets;

enum BMFontFileType
{
	TEXT(text:String);
	XML(xml:Xml);
	BINARY(bytes:Bytes);
}

class BMFontFileTypeHelper
{
	public static function guessType(data:FlxAngelCodeXmlAsset)
	{
		if (data is Xml)
		{
			return XML(cast(data, Xml));
		}
		var bytes: Bytes = null;
		
		if (data is String)
		{
			var dataStr: String = cast data;
			if (Assets.exists(dataStr))
			{
				// dataStr is a file path
				bytes = Assets.getBytes(dataStr);
				if(bytes == null)
				{
					bytes = Bytes.ofString(Assets.getText(dataStr));
				}
			}
			else
			{
				// dataStr is the content of a file as a string (can be xml or just plain text)
				var xml = safeParseXML(dataStr);
				if (xml != null && xml.firstElement() != null)
				{
					return XML(xml.firstElement());
				}
				return TEXT(dataStr);
			}
		}
		if(bytes != null)
		{
			// case when file is either of Bytes type or file was a path to a file
			var fileBytes:Bytes = cast bytes;
			var expected = [66, 77, 70]; // 'B', 'M', 'F'
			var isBinary = true;
			for (i in 0...expected.length)
			{
				if (fileBytes.get(i) != expected[i])
				{
					isBinary = false;
					break;
				}
			}
			if (isBinary)
				return BINARY(fileBytes);
			
			// at this point the bytes are really just text
			var text = fileBytes.toString();
			
			var xml = safeParseXML(text);
			if (xml != null && xml.firstElement() != null)
			{
				return XML(xml.firstElement());
			}
			return TEXT(text);
		}
		else if (data is Bytes)
		{
			var dataBytes:Bytes = cast data;
			var expected = [66, 77, 70]; // 'B', 'M', 'F'
			var isBinary = true;
			for (i in 0...expected.length)
			{
				if (dataBytes.get(i) != expected[i])
				{
					isBinary = false;
					break;
				}
			}
			if (isBinary)
				return BINARY(dataBytes);
		}
		throw 'Invalid bmfont descriptor file!';
	}

	static function safeParseXML(str: String)
	{
		// for js, Xml.parse throws if str is not valid XML but on desktop it just returns null
		// This function will always return null if xml is invalid
		try {
			var xml = Xml.parse(str);
			return xml;
		} catch(e: Dynamic)
		{
			return null;
		}
	}
}
