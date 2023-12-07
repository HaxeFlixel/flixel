package flixel.graphics.frames.bmfontutils;

import haxe.xml.Access;

private typedef BMFontInfoBlockRaw =
{
	var fontSize:Int;
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
	var fontName:String;
};

@:forward
abstract BMFontInfoBlock(BMFontInfoBlockRaw) from BMFontInfoBlockRaw
{
	public inline function new()
	{
		this =
		{
			fontSize: -1,
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
			fontName: ''
		}
	}
	
	public static function fromXml(infoNode:Access):BMFontInfoBlock
	{
		final padding:String = infoNode.att.padding;
		final paddingArr = padding.split(',').map(Std.parseInt);
		
		final spacing:String = infoNode.att.spacing;
		final spacingArr = spacing.split(',').map(Std.parseInt);
		
		final outline = infoNode.has.outline ? Std.parseInt(infoNode.att.outline) : 0;
		return {
			fontSize: Std.parseInt(infoNode.att.size),
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
			fontName: infoNode.att.face
		}
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
			chnl: -1
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
		};
	}
	
	public static function listFromXml(charsNode:Access):Array<BMFontCharBlock>
	{
		final chars = charsNode.nodes.char;
		return [ for (char in chars) fromXml(char) ];
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
@:access(flixel.graphics.frames.bmfontutils.BMFont)
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
}