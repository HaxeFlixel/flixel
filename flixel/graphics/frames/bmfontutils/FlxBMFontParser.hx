package flixel.graphics.frames.bmfontutils;

import flixel.FlxG;
import flixel.graphics.frames.bmfontutils.BMFont.BMFontCharBlock;
import flixel.graphics.frames.bmfontutils.BMFont.BMFontCommonBlock;
import flixel.graphics.frames.bmfontutils.BMFont.BMFontInfoBlock;
import flixel.graphics.frames.bmfontutils.BMFont.BMFontKerningPair;
import flixel.graphics.frames.bmfontutils.BMFont.BMFontPageInfoBlock;
import flixel.system.FlxAssets.FlxAngelCodeAsset;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.BytesInput;

using StringTools;

/**
 * A class that can parse the font descriptor files generated by AngelCode's BMFont tool
 */
class FlxBMFontParser
{
	public static function parse(data:FlxAngelCodeAsset)
	{
		final angelCodeDataType = BMFontFileTypeHelper.guessType(data);
		final fontInfo = switch angelCodeDataType
		{
			case TEXT(text):
				fromText(text);
			case XML(xml):
				BMFont.fromXml(xml);
			case BINARY(bytes):
				fromBinary(bytes);
		};
		return fontInfo;
	}
	
	static function fromText(text:String)
	{
		return new FlxBMFontTextParser(text).parse();
	}
	
	static function fromBinary(bytes:Bytes)
	{
		return new FlxBMFontBinaryParser(new BytesInput(bytes)).parse();
	}
}

@:access(flixel.graphics.frames.bmfontutils.BMFont)
class FlxBMFontBinaryParser
{
	var bytesInput:BytesInput;
	
	public static inline var BT_INFO:Int = 1;
	public static inline var BT_COMMON:Int = 2;
	public static inline var BT_PAGES:Int = 3;
	public static inline var BT_CHARS:Int = 4;
	public static inline var BT_KERNING_PAIRS:Int = 5;
	
	public function new(input:BytesInput)
	{
		bytesInput = input;
	}
	
	// @see https://www.angelcode.com/products/bmfont/doc/file_format.html#bin
	public function parse()
	{
		final fontInfo = new BMFont();
		final expectedBytes = [66, 77, 70]; // 'B', 'M', 'F'
		for (b in expectedBytes)
		{
			var testByte = bytesInput.readByte();
			if (testByte != b)
				throw 'Invalid binary .fnt file. Found $testByte, expected $b';
		}
		var version = bytesInput.readByte();
		if (version < 3)
		{
			FlxG.log.warn('The BMFont parser is made to work on files with version 3. Using earlier versions can cause issues!');
		}
		
		// parsing blocks
		while (bytesInput.position < bytesInput.length)
		{
			var blockId = bytesInput.readByte();
			switch blockId
			{
				case BT_INFO:
					fontInfo.info = parseInfoBlock();
				case BT_COMMON:
					fontInfo.common = parseCommonBlock();
				case BT_PAGES:
					fontInfo.pages = parsePagesBlock();
				case BT_CHARS:
					fontInfo.chars = parseCharsBlock();
				case BT_KERNING_PAIRS:
					fontInfo.kerningPairs = parseKerningPairs();
			}
		}
		return fontInfo;
	}
	
	function parseInfoBlock()
	{
		var blockSize:Int = bytesInput.readInt32();
		var fontSize = bytesInput.readInt16();
		var bitField = bytesInput.readByte();
		var fontInfo:BMFontInfoBlock = {
			fontSize: fontSize,
			smooth: (bitField & 0x80) != 0,
			unicode: (bitField & (0x80 >> 1)) != 0,
			italic: (bitField & (0x80 >> 2)) != 0,
			bold: (bitField & (0x80 >> 3)) != 0,
			fixedHeight: (bitField & (0x80 >> 4)) != 0,
			charSet: String.fromCharCode(bytesInput.readByte()),
			stretchH: bytesInput.readInt16(),
			aa: bytesInput.readByte(),
			paddingUp: bytesInput.readByte(),
			paddingRight: bytesInput.readByte(),
			paddingDown: bytesInput.readByte(),
			paddingLeft: bytesInput.readByte(),
			spacingHoriz: bytesInput.readByte(),
			spacingVert: bytesInput.readByte(),
			outline: bytesInput.readByte(),
			fontName: bytesInput.readString(blockSize - 14 - 1)
		};
		bytesInput.readByte(); // skip the null terminator of the string
		return fontInfo;
	}
	
	function parseCommonBlock()
	{
		var blockSize = bytesInput.readInt32();
		
		var lineHeight = bytesInput.readInt16();
		var base = bytesInput.readInt16();
		var scaleW = bytesInput.readInt16();
		var scaleH = bytesInput.readInt16();
		var pages = bytesInput.readInt16();
		var bitField = bytesInput.readByte();
		var isPacked = (bitField & 0x2) != 0;
		var commonBlock:BMFontCommonBlock = {
			lineHeight: lineHeight,
			base: base,
			scaleW: scaleW,
			scaleH: scaleH,
			pages: pages,
			isPacked: isPacked,
			alphaChnl: bytesInput.readByte(),
			redChnl: bytesInput.readByte(),
			greenChnl: bytesInput.readByte(),
			blueChnl: bytesInput.readByte(),
		};
		if (blockSize != 15)
			throw 'Invalid block size for common block. Expected 15 got $blockSize';
		return commonBlock;
	}
	
	function parsePagesBlock()
	{
		var blockSize = bytesInput.readInt32();
		var pagesBlock:Array<BMFontPageInfoBlock> = [];
		
		var bytesRead = 0;
		var i = 0;
		while (bytesRead < blockSize)
		{
			var bytesBuf = new BytesBuffer();
			var curByte = bytesInput.readByte();
			while (curByte != 0)
			{
				bytesBuf.addByte(curByte);
				curByte = bytesInput.readByte();
			}
			var pageName = bytesBuf.getBytes().toString();
			pagesBlock.push({id: i, file: pageName});
			bytesRead += pageName.length + 1;
			i++;
		}
		
		return pagesBlock;
	}
	
	function parseCharsBlock()
	{
		var blockSize = bytesInput.readInt32();
		var bytesRead = 0;
		var chars = [];
		while (bytesRead < blockSize)
		{
			var charInfo:BMFontCharBlock = {
				id: bytesInput.readInt32(),
				x: bytesInput.readInt16(),
				y: bytesInput.readInt16(),
				width: bytesInput.readInt16(),
				height: bytesInput.readInt16(),
				xoffset: bytesInput.readInt16(),
				yoffset: bytesInput.readInt16(),
				xadvance: bytesInput.readInt16(),
				page: bytesInput.readByte(),
				chnl: bytesInput.readByte(),
			};
			chars.push(charInfo);
			bytesRead += 20;
		}
		return chars;
	}
	
	function parseKerningPairs()
	{
		var blockSize = bytesInput.readInt32();
		var bytesRead = 0;
		var kerningPairs = [];
		while (bytesRead < blockSize)
		{
			var kerningPair:BMFontKerningPair = {
				first: bytesInput.readInt32(),
				second: bytesInput.readInt32(),
				amount: bytesInput.readInt16(),
			};
			kerningPairs.push(kerningPair);
			bytesRead += 10;
		}
		return kerningPairs;
	}
}

@:access(flixel.graphics.frames.bmfontutils.BMFont)
class FlxBMFontTextParser
{
	var text:String;
	
	public function new(text:String)
	{
		this.text = text;
	}
	
	public function parse()
	{
		var fontInfo = new BMFont();
		var lines = text.replace('\r\n', '\n').split('\n').filter((line) -> line.length > 0);
		for (line in lines)
		{
			var blockType = line.substring(0, line.indexOf(' '));
			var blockAttrs = line.substring(line.indexOf(' ') + 1);
			switch blockType
			{
				case 'info':
					fontInfo.info = parseInfoBlock(blockAttrs);
				case 'common':
					fontInfo.common = parseCommonBlock(blockAttrs);
				case 'page':
					fontInfo.pages.push(parsePageBlock(blockAttrs));
				// case 'chars': // we dont need this but this field exists in the file
				case 'char':
					fontInfo.chars.push(parseCharBlock(blockAttrs));
				// case 'kernings': // we dont need this but this field exists in the file
				case 'kerning':
					fontInfo.kerningPairs.push(parseKerningPair(blockAttrs));
			}
		}
		return fontInfo;
	}
	
	function parseInfoBlock(attrs:String)
	{
		var info:BMFontInfoBlock = new BMFontInfoBlock();
		
		// the parsing here is a bit more involved since strings can have spaces within them
		// so we can't just split by space like we usually do (same goes for parsePageBlock and parseCharBlock)
		var i = 0;
		var word = '';
		var readNumberLike = () ->
		{
			i += 2; // skip '='
			word = '';
			while (attrs.charAt(i) != ' ')
			{
				word += attrs.charAt(i);
				i++;
			}
			i++; // skip space
			return word;
		};
		var readString = () ->
		{
			i += 3; // skip '=' and start quote
			word = '';
			while (attrs.charAt(i) != '\"')
			{
				word += attrs.charAt(i);
				i++;
			}
			i++; // skip end quote
			return word;
		};
		while (true)
		{
			if (i >= attrs.length)
				break;
			var curChar = attrs.charAt(i);
			if (curChar == '')
				break;
			if (curChar == ' ')
			{
				i++;
				continue;
			}
			word += curChar;
			switch word
			{
				case 'face':
					info.fontName = readString();
					word = '';
				case 'size':
					info.fontSize = Std.parseInt(readNumberLike());
					word = '';
				case 'bold':
					info.bold = readNumberLike() != '0';
					word = '';
				case 'italic':
					info.italic = readNumberLike() != '0';
					word = '';
				case 'charset':
					info.charSet = readString();
					word = '';
				case 'unicode':
					info.unicode = readNumberLike() != '0';
					word = '';
				case 'stretchH':
					info.stretchH = Std.parseInt(readNumberLike());
					word = '';
				case 'smooth':
					info.smooth = readNumberLike() != '0';
					word = '';
				case 'aa':
					info.aa = Std.parseInt(readNumberLike());
					word = '';
				case 'padding':
					var paddings = readNumberLike().split(',').map(Std.parseInt);
					info.paddingUp = paddings[0];
					info.paddingRight = paddings[1];
					info.paddingDown = paddings[2];
					info.paddingLeft = paddings[3];
					word = '';
				case 'spacing':
					var spacings = readNumberLike().split(',').map(Std.parseInt);
					info.spacingHoriz = spacings[0];
					info.spacingVert = spacings[1];
					word = '';
				case 'outline':
					info.outline = Std.parseInt(readNumberLike());
					word = '';
				case 'fixedHeight':
					info.fixedHeight = readNumberLike() != '0';
					word = '';
			}
			i++;
		}
		return info;
	}
	
	function parseCommonBlock(attrs:String)
	{
		var common:BMFontCommonBlock = new BMFontCommonBlock();
		var keyValuePairs = attrs.split(' ').map((s) -> s.split('='));
		for (kvPair in keyValuePairs)
		{
			var key = kvPair[0];
			var value = kvPair[1];
			switch key
			{
				case 'lineHeight':
					common.lineHeight = Std.parseInt(value);
				case 'base':
					common.base = Std.parseInt(value);
				case 'scaleW':
					common.scaleW = Std.parseInt(value);
				case 'scaleH':
					common.scaleH = Std.parseInt(value);
				case 'pages':
					common.pages = Std.parseInt(value);
				case 'packed':
					common.isPacked = value != '0';
				case 'alphaChnl':
					common.alphaChnl = Std.parseInt(value);
				case 'redChnl':
					common.redChnl = Std.parseInt(value);
				case 'greenChnl':
					common.greenChnl = Std.parseInt(value);
				case 'blueChnl':
					common.blueChnl = Std.parseInt(value);
			}
		}
		
		return common;
	}
	
	function parsePageBlock(attrs:String)
	{
		var page:BMFontPageInfoBlock = new BMFontPageInfoBlock(-1, '');
		var i = 0;
		var word = '';
		var readNumberLike = () ->
		{
			i += 2; // skip '='
			word = '';
			while (attrs.charAt(i) != ' ')
			{
				word += attrs.charAt(i);
				i++;
			}
			i++; // skip space
			return word;
		};
		var readString = () ->
		{
			i += 3; // skip '=' and start quote
			word = '';
			while (attrs.charAt(i) != '\"')
			{
				word += attrs.charAt(i);
				i++;
			}
			i++; // skip end quote
			return word;
		};
		while (true)
		{
			if (i >= attrs.length)
				break;
			var curChar = attrs.charAt(i);
			if (curChar == '')
			{
				break;
			}
			else if (curChar == ' ')
			{
				i++;
				continue;
			}
			
			word += curChar;
			switch word
			{
				case 'id':
					page.id = Std.parseInt(readNumberLike());
					word = '';
				case 'file':
					page.file = readString();
					word = '';
			}
			i++;
		}
		return page;
	}
	
	function parseCharBlock(attrs:String)
	{
		var char:BMFontCharBlock = new BMFontCharBlock();
		var i = 0;
		var word = '';
		var readNumberLike = () ->
		{
			i += 2; // skip '='
			word = '';
			while (attrs.charAt(i) != ' ')
			{
				word += attrs.charAt(i);
				i++;
			}
			i++; // skip space
			return word;
		};
		var readString = () ->
		{
			i += 3; // skip '=' and start quote
			// hack needed here specifically because bmfont does not escape double-quotes :(
			if (attrs.charAt(i) == '"' && attrs.charAt(i + 1) == '"')
			{
				return '"';
			}
			word = '';
			while (attrs.charAt(i) != '\"' && i < attrs.length)
			{
				word += attrs.charAt(i);
				i++;
			}
			i++; // skip end quote
			return word;
		};
		
		while (true)
		{
			if (i >= attrs.length)
				break;
			var curChar = attrs.charAt(i);
			if (curChar == '')
				break;
			if (curChar == ' ')
			{
				i++;
				continue;
			}
			word += curChar;
			var nextChar = attrs.charAt(i + 1);
			switch word
			{
				case 'letter':
					char.id = BMFontCharBlock.getCorrectLetter(readString()).charCodeAt(0);
					word = '';
				case 'id':
					char.id = Std.parseInt(readNumberLike());
					word = '';
				case 'x':
					if (nextChar == '=')
					{
						char.x = Std.parseInt(readNumberLike());
						word = '';
					}
				case 'y':
					if (nextChar == '=')
					{
						char.y = Std.parseInt(readNumberLike());
						word = '';
					}
				case 'width':
					char.width = Std.parseInt(readNumberLike());
					word = '';
				case 'height':
					char.height = Std.parseInt(readNumberLike());
					word = '';
				case 'xoffset':
					var xoffset = Std.parseInt(readNumberLike());
					char.xoffset = (xoffset == null) ? 0 : xoffset;
					word = '';
				case 'yoffset':
					var yoffset = Std.parseInt(readNumberLike());
					char.yoffset = (yoffset == null) ? 0 : yoffset;
					word = '';
				case 'xadvance':
					var xadvance = Std.parseInt(readNumberLike());
					char.xadvance = (xadvance == null) ? 0 : xadvance;
					word = '';
				case 'page':
					char.page = Std.parseInt(readNumberLike());
					word = '';
				case 'chnl':
					char.chnl = Std.parseInt(readNumberLike());
					word = '';
			}
			i++;
		}
		return char;
	}
	
	function parseKerningPair(attrs:String)
	{
		var kerningPair:BMFontKerningPair = new BMFontKerningPair();
		var keyValuePairs = attrs.split(' ').map((s) -> s.split('='));
		for (kvPair in keyValuePairs)
		{
			var key = kvPair[0];
			var value = kvPair[1];
			
			switch key
			{
				case 'first':
					kerningPair.first = Std.parseInt(value);
				case 'second':
					kerningPair.second = Std.parseInt(value);
				case 'amount':
					kerningPair.amount = Std.parseInt(value);
			}
		}
		return kerningPair;
	}
}