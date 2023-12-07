package flixel.graphics.frames.bmfont;

import flixel.graphics.frames.bmfont.FlxBMFontParser;
import haxe.xml.Access;
import UnicodeString;

using StringTools;

private typedef BMFontInfoBlockRaw =
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
abstract BMFontInfoBlock(BMFontInfoBlockRaw) from BMFontInfoBlockRaw
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
	
	public static function fromXml(infoNode:Access):BMFontInfoBlock
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
		final info:BMFontInfoBlock = new BMFontInfoBlock();
		
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
}

private typedef BMFontCommonBlockRaw =
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
abstract BMFontCommonBlock(BMFontCommonBlockRaw) from BMFontCommonBlockRaw
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
	
	public static function fromXml(commonNode:Access):BMFontCommonBlock
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
		final common:BMFontCommonBlock = new BMFontCommonBlock();
		
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
}

private typedef BMFontPageInfoBlockRaw =
{
	var id:Int;
	var file:String;
};

@:forward
abstract BMFontPageInfoBlock(BMFontPageInfoBlockRaw) from BMFontPageInfoBlockRaw
{
	public inline function new(id, file)
	{
		this =
		{
			id: id,
			file: file
		}
	}
	
	public static function fromXml(pageNode:Access):BMFontPageInfoBlock
	{
		return
		{
			id: Std.parseInt(pageNode.att.id),
			file: pageNode.att.file
		}
	}
	
	public static function listFromXml(pagesNode:Access):Array<BMFontPageInfoBlock>
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
		return new BMFontPageInfoBlock(id, file);
	}
}

private typedef BMFontCharBlockRaw =
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
abstract BMFontCharBlock(BMFontCharBlockRaw) from BMFontCharBlockRaw
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
	
	public static function listFromXml(charsNode:Access):Array<BMFontCharBlock>
	{
		final chars = charsNode.nodes.char;
		return [ for (char in chars) fromXml(char) ];
	}
	
	public static function fromText(kerningText:String):BMFontCharBlock
	{
		final char = new BMFontCharBlock();
		
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

private typedef BMFontKerningPairRaw =
{
	var first:Int;
	var second:Int;
	var amount:Int;
};

@:forward
@:access(flixel.graphics.frames.bmfont.BMFont)
abstract BMFontKerningPair(BMFontKerningPairRaw) from BMFontKerningPairRaw
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
	
	public static function fromXml(kerningNode:Access):BMFontKerningPair
	{
		return
		{
			first: Std.parseInt(kerningNode.att.first),
			second: Std.parseInt(kerningNode.att.second),
			amount: Std.parseInt(kerningNode.att.amount)
		}
	}
	
	public static function listFromXml(kerningsNode:Access):Array<BMFontKerningPair>
	{
		final kernings = kerningsNode.nodes.kerning;
		return [ for (pair in kernings) fromXml(pair) ];
	}
	
	public static function fromText(kerningText:String):BMFontKerningPair
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
		return new BMFontKerningPair(first, second, amount);
	}
	
	// public static function listFromText(kerningsText:String):Array<BMFontKerningPair>
	// {
		
	// }
}

class BMFont
{
	public var info:BMFontInfoBlock;
	public var common:BMFontCommonBlock;
	public var pages:Array<BMFontPageInfoBlock>;
	public var chars:Array<BMFontCharBlock>;
	public var kerningPairs:Null<Array<BMFontKerningPair>> = null;
	
	function new(?info, ?common, ?pages, ?chars, ?kerningPairs)
	{
		this.info = info;
		this.common = common;
		this.pages = pages;
		this.chars = chars;
		this.kerningPairs = kerningPairs;
	}
	
	public static function fromXml(xml:Xml)
	{
		final xmlAccess = new Access(xml);
		final info = BMFontInfoBlock.fromXml(xmlAccess.node.info);
		final common = BMFontCommonBlock.fromXml(xmlAccess.node.common);
		final pages = BMFontPageInfoBlock.listFromXml(xmlAccess.node.pages);
		final chars = BMFontCharBlock.listFromXml(xmlAccess.node.chars);
		var kerningPairs:Array<BMFontKerningPair> = null;
		
		if (xmlAccess.hasNode.kernings)
		{
			kerningPairs = BMFontKerningPair.listFromXml(xmlAccess.node.kernings);
		}
		
		return new BMFont(info, common, pages, chars, kerningPairs);
	}
	
	public static function fromText(text:String)
	{
		var info:BMFontInfoBlock = null;
		var common:BMFontCommonBlock = null;
		final pages = new Array<BMFontPageInfoBlock>();
		final chars = new Array<BMFontCharBlock>();
		final kernings = new Array<BMFontKerningPair>();
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
				case 'info': info = BMFontInfoBlock.fromText(blockAttrs);
				case 'common': common = BMFontCommonBlock.fromText(blockAttrs);
				case 'page': pages.push(BMFontPageInfoBlock.fromText(blockAttrs));
				// case 'chars': charCount = Std.parseInt(blockAttrs.split("=").pop());
				case 'char': chars.push(BMFontCharBlock.fromText(blockAttrs));
				// case 'kernings': kerningCount = Std.parseInt(blockAttrs.split("=").pop());
				case 'kerning': kernings.push(BMFontKerningPair.fromText(blockAttrs));
			}
		}
		
		return new BMFont(info, common, pages, chars, kernings.length > 0 ? kernings : null);
	}
}