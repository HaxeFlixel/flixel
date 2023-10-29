package flixel.graphics.frames.bmfontutils;

import flixel.system.FlxAssets.FlxAngelCodeAsset;
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
	/**
	 * A helper function that helps determine the type of BMFont descriptor from either the path or content of the file
	 * @param data The file path or the file content
	 * @return BMFontFileType
	 */
	public static function guessType(data:FlxAngelCodeAsset):BMFontFileType
	{
		if (data is Xml)
		{
			return XML(cast(data, Xml).firstElement());
		}
		else if (data is String)
		{
			var dataStr: String = cast data;
			if (Assets.exists(dataStr))
			{
				// dataStr is a file path
				var bytes = Assets.getBytes(dataStr);
				if(bytes == null)
				{
					return detectFromText(Assets.getText(dataStr));
				}
				var fileType = detectFromBytes(bytes);
				if (fileType == null)
				{
					return detectFromText(bytes.toString());
				}
				return detectFromBytes(bytes);
			}
			else
			{
				// dataStr is the content of a file as a string (can be xml or just plain text)
				return detectFromText(dataStr);
			}
		}
		else if (data is Bytes)
		{
			var bytes:Bytes = cast data;
			var fileType = detectFromBytes(bytes);
			if (fileType == null)
			{
				return detectFromText(bytes.toString());
			}
		}
		return null;
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
		var xml = safeParseXML(text);
		if (xml != null && xml.firstElement() != null)
		{
			return XML(xml.firstElement());
		}
		return TEXT(text);
	}
	static function detectFromBytes(bytes:Bytes):Null<BMFontFileType>
	{
		var expected = [66, 77, 70]; // 'B', 'M', 'F'
		var isBinary = true;
		for (i in 0...expected.length)
		{
			if (bytes.get(i) != expected[i])
			{
				isBinary = false;
				break;
			}
		}
		if (isBinary)
			return BINARY(bytes);
		return null;
	}
}
