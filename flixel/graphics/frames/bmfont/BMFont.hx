package flixel.graphics.frames.bmfont;

import flixel.graphics.frames.bmfont.FlxBMFontParser;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesBuffer;
import haxe.xml.Access;
import UnicodeString;

using StringTools;

private typedef BMFontInfoRaw =
{
	var size:Int;
	var smooth:Bool;
	var unicode:Bool;
	var italic:Bool;
	var bold:Bool;
	var fixedHeight:Bool;
	var charSet:String;
	var stretchH:Int;
	var aa:Int;
	var paddingUp:Int;
	var paddingRight:Int;
	var paddingDown:Int;
	var paddingLeft:Int;
	var spacingHoriz:Int;
	var spacingVert:Int;
	var outline:Int;
	/** font name */
	var face:String;
};

@:forward
abstract BMFontInfo(BMFontInfoRaw) from BMFontInfoRaw
{
	public inline function new()
	{
		this =
		{
			size: -1,
			smooth: false,
			unicode: false,
			italic: false,
			bold: false,
			fixedHeight: false,
			charSet: '',
			stretchH: 100,
			aa: 1,
			paddingUp: 0,
			paddingRight: 0,
			paddingDown: 0,
			paddingLeft: 0,
			spacingHoriz: 0,
			spacingVert: 0,
			outline: 0,
			face: ''
		}
	}
	
	inline function setPaddingsFromString(values:String)
	{
		final paddings = values.split(',');
		this.paddingUp = Std.parseInt(paddings[0]);
		this.paddingRight = Std.parseInt(paddings[1]);
		this.paddingDown = Std.parseInt(paddings[2]);
		this.paddingLeft = Std.parseInt(paddings[3]);
	}
	
	inline function setSpacingsFromString(values:String)
	{
		final spacings = values.split(',');
		this.spacingHoriz = Std.parseInt(spacings[0]);
		this.spacingVert = Std.parseInt(spacings[1]);
	}
	
	public static function fromXml(infoNode:Access):BMFontInfo
	{
		final padding:String = infoNode.att.padding;
		final paddingArr = padding.split(',').map(Std.parseInt);
		
		final spacing:String = infoNode.att.spacing;
		final spacingArr = spacing.split(',').map(Std.parseInt);
		
		final outline = infoNode.has.outline ? Std.parseInt(infoNode.att.outline) : 0;
		return {
			size: Std.parseInt(infoNode.att.size),
			smooth: infoNode.att.smooth != '0',
			unicode: infoNode.att.unicode != '0',
			italic: infoNode.att.italic != '0',
			bold: infoNode.att.bold != '0',
			fixedHeight: infoNode.has.fixedHeight && infoNode.att.fixedHeight != '0',
			charSet: infoNode.att.charset,
			stretchH: Std.parseInt(infoNode.att.stretchH),
			aa: Std.parseInt(infoNode.att.aa),
			paddingUp: paddingArr[0],
			paddingRight: paddingArr[1],
			paddingDown: paddingArr[2],
			paddingLeft: paddingArr[3],
			spacingHoriz: spacingArr[0],
			spacingVert: spacingArr[1],
			outline: outline,
			face: infoNode.att.face
		}
	}
	
	public static function fromText(infoText:String)
	{
		final info:BMFontInfo = new BMFontInfo();
		
		BMFontTextAttributeParser.forEachAttribute(infoText,
			function(key:String, value:UnicodeString)
			{
				switch key
				{
					case 'face': info.face = value;
					case 'size': info.size = Std.parseInt(value);
					case 'bold': info.bold = value != '0';
					case 'italic': info.italic = value != '0';
					case 'charset': info.charSet = value;
					case 'unicode': info.unicode = value != '0';
					case 'stretchH': info.stretchH = Std.parseInt(value);
					case 'smooth': info.smooth = value != '0';
					case 'aa': info.aa = Std.parseInt(value);
					case 'padding': info.setPaddingsFromString(value);
					case 'spacing': info.setSpacingsFromString(value);
					case 'outline': info.outline = Std.parseInt(value);
					case 'fixedHeight': info.fixedHeight = value != '0';
				}
			}
		);
		
		return info;
	}
	
	public static function fromBytes(bytes:BytesInput)
	{
		final blockSize = bytes.readInt32();
		final bitField = bytes.readByte();
		final fontInfo:BMFontInfo = {
			size: bytes.readInt16(),
			smooth: (bitField & 0x80) != 0,
			unicode: (bitField & (0x80 >> 1)) != 0,
			italic: (bitField & (0x80 >> 2)) != 0,
			bold: (bitField & (0x80 >> 3)) != 0,
			fixedHeight: (bitField & (0x80 >> 4)) != 0,
			charSet: String.fromCharCode(bytes.readByte()),
			stretchH: bytes.readInt16(),
			aa: bytes.readByte(),
			paddingUp: bytes.readByte(),
			paddingRight: bytes.readByte(),
			paddingDown: bytes.readByte(),
			paddingLeft: bytes.readByte(),
			spacingHoriz: bytes.readByte(),
			spacingVert: bytes.readByte(),
			outline: bytes.readByte(),
			face: bytes.readString(blockSize - 14 - 1)
		};
		bytes.readByte(); // skip the null terminator of the string
		return fontInfo;
	}
}

private typedef BMFontCommonRaw =
{
	var lineHeight:Int;
	var base:Int;
	var scaleW:Int;
	var scaleH:Int;
	var pages:Int;
	var isPacked:Bool;
	var alphaChnl:Int;
	var redChnl:Int;
	var greenChnl:Int;
	var blueChnl:Int;
};

@:forward
abstract BMFontCommon(BMFontCommonRaw) from BMFontCommonRaw
{
	public inline function new ()
	{
		this =
		{
			lineHeight: -1,
			base: -1,
			scaleW: 1,
			scaleH: 1,
			pages: 0,
			isPacked: false,
			alphaChnl: -1,
			redChnl: -1,
			greenChnl: -1,
			blueChnl: -1,
		};
	}
	
	public static function fromXml(commonNode:Access)
	{
		final alphaChnl = (commonNode.has.alphaChnl) ? Std.parseInt(commonNode.att.alphaChnl) : 0;
		final redChnl = (commonNode.has.redChnl) ? Std.parseInt(commonNode.att.redChnl) : 0;
		final greenChnl = (commonNode.has.greenChnl) ? Std.parseInt(commonNode.att.greenChnl) : 0;
		final blueChnl = (commonNode.has.blueChnl) ? Std.parseInt(commonNode.att.blueChnl) : 0;
		return {
			lineHeight: Std.parseInt(commonNode.att.lineHeight),
			base: Std.parseInt(commonNode.att.base),
			scaleW: Std.parseInt(commonNode.att.scaleW),
			scaleH: Std.parseInt(commonNode.att.scaleH),
			pages: Std.parseInt(commonNode.att.pages),
			isPacked: commonNode.att.packed != '0',
			alphaChnl: alphaChnl,
			redChnl: redChnl,
			greenChnl: greenChnl,
			blueChnl: blueChnl
		};
	}
	
	public static function fromText(commonText:String)
	{
		final common:BMFontCommon = new BMFontCommon();
		
		BMFontTextAttributeParser.forEachAttribute(commonText,
			function(key:String, value:UnicodeString)
			{
				switch key
				{
					case 'lineHeight': common.lineHeight = Std.parseInt(value);
					case 'base': common.base = Std.parseInt(value);
					case 'scaleW': common.scaleW = Std.parseInt(value);
					case 'scaleH': common.scaleH = Std.parseInt(value);
					case 'pages': common.pages = Std.parseInt(value);
					case 'packed': common.isPacked = value != '0';
					case 'alphaChnl': common.alphaChnl = Std.parseInt(value);
					case 'redChnl': common.redChnl = Std.parseInt(value);
					case 'greenChnl': common.greenChnl = Std.parseInt(value);
					case 'blueChnl': common.blueChnl = Std.parseInt(value);
				}
			}
		);
		
		return common;
	}
	
	public static function fromBytes(bytes:BytesInput)
	{
		final blockSize = bytes.readInt32();
		if (blockSize != 15)
			throw 'Invalid block size for common block. Expected 15 got $blockSize';
		
		return {
			lineHeight: bytes.readInt16(),
			base: bytes.readInt16(),
			scaleW: bytes.readInt16(),
			scaleH: bytes.readInt16(),
			pages: bytes.readInt16(),
			isPacked: (bytes.readByte() & 0x2) != 0,
			alphaChnl: bytes.readByte(),
			redChnl: bytes.readByte(),
			greenChnl: bytes.readByte(),
			blueChnl: bytes.readByte(),
		};
	}
}

private typedef BMFontPageRaw =
{
	var id:Int;
	var file:String;
};

@:forward
abstract BMFontPage(BMFontPageRaw) from BMFontPageRaw
{
	public inline function new(id, file)
	{
		this =
		{
			id: id,
			file: file
		}
	}
	
	public static function fromXml(pageNode:Access):BMFontPage
	{
		return
		{
			id: Std.parseInt(pageNode.att.id),
			file: pageNode.att.file
		}
	}
	
	public static function listFromXml(pagesNode:Access):Array<BMFontPage>
	{
		final pages = pagesNode.nodes.page;
		return [for (page in pages) fromXml(page) ];
	}
	
	public static function fromText(pageText:String)
	{
		var id = -1;
		var file:String = null;
		BMFontTextAttributeParser.forEachAttribute(pageText, 
			function(key:String, value:UnicodeString)
			{
				switch key
				{
					case 'id': id = Std.parseInt(value);
					case 'file': file = value;
					default: FlxG.log.warn('Unexpected font char attribute: $key=$value');
				}
			}
		);
		return new BMFontPage(id, file);
	}
	
	public static function listFromBytes(bytes:BytesInput)
	{
		var blockSize = bytes.readInt32();
		final pages = new Array<BMFontPage>();
		
		var i = 0;
		while (blockSize < 0)
		{
			final bytesBuf = new BytesBuffer();
			var curByte = bytes.readByte();
			while (curByte != 0)
			{
				bytesBuf.addByte(curByte);
				curByte = bytes.readByte();
			}
			final pageName = bytesBuf.getBytes().toString();
			pages.push({id: i, file: pageName});
			blockSize -= pageName.length + 1;
			i++;
		}
		
		return pages;
	}
}

private typedef BMFontCharRaw =
{
	var id:Int;
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
	var xoffset:Int;
	var yoffset:Int;
	var xadvance:Int;
	var page:Int;
	var chnl:Int;
	var letter:String;
};

@:forward
abstract BMFontChar(BMFontCharRaw) from BMFontCharRaw
{
	public inline function new()
	{
		this = 
		{
			id: -1,
			x: -1,
			y: -1,
			width: 0,
			height: 0,
			xoffset: 0,
			yoffset: 0,
			xadvance: 0,
			page: -1,
			chnl: -1,
			letter: null
		}
	}
	
	public static inline function fromXml(charNode:Access)
	{
		final char = charNode;
		final id = (char.has.letter) ? getCorrectLetter(char.att.letter).charCodeAt(0) : Std.parseInt(char.att.id);
		final xoffset = (char.has.xoffset) ? Std.parseInt(char.att.xoffset) : 0;
		final yoffset = (char.has.yoffset) ? Std.parseInt(char.att.yoffset) : 0;
		final xadvance = (char.has.xadvance) ? Std.parseInt(char.att.xadvance) : 0;
		return {
			id: id,
			x: Std.parseInt(char.att.x),
			y: Std.parseInt(char.att.y),
			width: Std.parseInt(char.att.width),
			height: Std.parseInt(char.att.height),
			xoffset: xoffset,
			yoffset: yoffset,
			xadvance: xadvance,
			page: Std.parseInt(char.att.page),
			chnl: Std.parseInt(char.att.chnl),
			letter: char.att.letter
		};
	}
	
	public static function listFromXml(charsNode:Access):Array<BMFontChar>
	{
		final chars = charsNode.nodes.char;
		return [ for (char in chars) fromXml(char) ];
	}
	
	public static function fromText(kerningText:String):BMFontChar
	{
		final char = new BMFontChar();
		
		BMFontTextAttributeParser.forEachAttribute(kerningText, 
			function(key:String, value:UnicodeString)
			{
				switch key
				{
					case 'id': char.id = Std.parseInt(value);
					case 'x': char.x = Std.parseInt(value);
					case 'y': char.y = Std.parseInt(value);
					case 'width': char.width = Std.parseInt(value);
					case 'height': char.height = Std.parseInt(value);
					case 'xoffset': char.xoffset = Std.parseInt(value);
					case 'yoffset': char.yoffset = Std.parseInt(value);
					case 'xadvance': char.xadvance = Std.parseInt(value);
					case 'page': char.page = Std.parseInt(value);
					case 'chnl': char.chnl = Std.parseInt(value);
					case 'letter': char.letter = value;
					default: FlxG.log.warn('Unexpected font char attribute: $key=$value');
				}
			}
		);
		
		// always true?
		if (char.letter != null)
			char.id = getCorrectLetter(char.letter).charCodeAt(0);
		
		return char;
	}
	
	public static function listFromBytes(bytes:BytesInput):Array<BMFontChar>
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
				chnl: bytes.readByte(),
				letter: null
			};
			chars.push(char);
			blockSize -= 20;
		}
		return chars;
	}
	
	public static function getCorrectLetter(letter:String)
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

private typedef BMFontKerningRaw =
{
	var first:Int;
	var second:Int;
	var amount:Int;
};

@:forward
@:access(flixel.graphics.frames.bmfont.BMFont)
abstract BMFontKerning(BMFontKerningRaw) from BMFontKerningRaw
{
	public inline function new(first = -1, second = -1, amount = 0)
	{
		this = 
		{
			first: first,
			second: second,
			amount: amount
		}
	}
	
	public static function fromXml(kerningNode:Access):BMFontKerning
	{
		return
		{
			first: Std.parseInt(kerningNode.att.first),
			second: Std.parseInt(kerningNode.att.second),
			amount: Std.parseInt(kerningNode.att.amount)
		}
	}
	
	public static function listFromXml(kerningsNode:Access):Array<BMFontKerning>
	{
		final kernings = kerningsNode.nodes.kerning;
		return [ for (pair in kernings) fromXml(pair) ];
	}
	
	public static function fromText(kerningText:String):BMFontKerning
	{
		var first:Int = -1;
		var second:Int = -1;
		var amount:Int = -1;
		BMFontTextAttributeParser.forEachAttribute(kerningText, 
			function(key:String, value:UnicodeString)
			{
				switch key
				{
					case 'first': first = Std.parseInt(value);
					case 'second': second = Std.parseInt(value);
					case 'amount': amount = Std.parseInt(value);
					// default: FlxG.log.warn('Unexpected font char attribute: $key=$value');
				}
			}
		);
		return new BMFontKerning(first, second, amount);
	}
	
	public static function listFromBytes(bytes:BytesInput)
	{
		var blockSize = bytes.readInt32();
		final kernings = new Array<BMFontKerning>();
		while (blockSize > 0)
		{
			final kerning =
			{
				first: bytes.readInt32(),
				second: bytes.readInt32(),
				amount: bytes.readInt16()
			};
			kernings.push(kerning);
			blockSize -= 10;// 4 + 4 + 2
		}
		return kernings;
	}
}

class BMFont
{
	public var info:BMFontInfo;
	public var common:BMFontCommon;
	public var pages:Array<BMFontPage>;
	public var chars:Array<BMFontChar>;
	public var kerning:Null<Array<BMFontKerning>> = null;
	
	function new(?info, ?common, ?pages, ?chars, ?kerning)
	{
		this.info = info;
		this.common = common;
		this.pages = pages;
		this.chars = chars;
		this.kerning = kerning;
	}
	
	public static function fromXml(xml:Xml)
	{
		final xmlAccess = new Access(xml);
		final info = BMFontInfo.fromXml(xmlAccess.node.info);
		final common = BMFontCommon.fromXml(xmlAccess.node.common);
		final pages = BMFontPage.listFromXml(xmlAccess.node.pages);
		final chars = BMFontChar.listFromXml(xmlAccess.node.chars);
		var kerning:Array<BMFontKerning> = null;
		
		if (xmlAccess.hasNode.kernings)
		{
			kerning = BMFontKerning.listFromXml(xmlAccess.node.kernings);
		}
		
		return new BMFont(info, common, pages, chars, kerning);
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
}

enum abstract BMFontBlockId(Int) from Int
{
	var INFO:Int = 1;
	var COMMON:Int = 2;
	var PAGES:Int = 3;
	var CHARS:Int = 4;
	var KERNING:Int = 5;
}