package flixel.graphics.frames.bmfont;

import haxe.io.BytesInput;
import haxe.xml.Access;

@:structInit
@:allow(flixel.graphics.frames.bmfont.BMFont)
class BMFontCommon
{
	public var lineHeight:Int;
	public var base:Int;
	public var scaleW:Int;
	public var scaleH:Int;
	public var pages:Int;
	public var packed:Bool;
	public var alphaChnl:Int;
	public var redChnl:Int;
	public var greenChnl:Int;
	public var blueChnl:Int;
	
	static function fromXml(commonNode:Access):BMFontCommon
	{
		return
		{
			lineHeight: Std.parseInt(commonNode.att.lineHeight),
			base: Std.parseInt(commonNode.att.base),
			scaleW: Std.parseInt(commonNode.att.scaleW),
			scaleH: Std.parseInt(commonNode.att.scaleH),
			pages: Std.parseInt(commonNode.att.pages),
			packed: commonNode.att.packed != '0',
			alphaChnl: (commonNode.has.alphaChnl) ? Std.parseInt(commonNode.att.alphaChnl) : 0,
			redChnl: (commonNode.has.redChnl) ? Std.parseInt(commonNode.att.redChnl) : 0,
			greenChnl: (commonNode.has.greenChnl) ? Std.parseInt(commonNode.att.greenChnl) : 0,
			blueChnl: (commonNode.has.blueChnl) ? Std.parseInt(commonNode.att.blueChnl) : 0
		};
	}
	
	static function fromText(commonText:String):BMFontCommon
	{
		var lineHeight:Int = -1;
		var base:Int = -1;
		var scaleW:Int = 1;
		var scaleH:Int = 1;
		var pages:Int = 0;
		var packed:Bool = false;
		var alphaChnl:Int = -1;
		var redChnl:Int = -1;
		var greenChnl:Int = -1;
		var blueChnl:Int = -1;
		
		BMFontUtil.forEachAttribute(commonText,
			function(key:String, value:String)
			{
				switch key
				{
					case 'lineHeight': lineHeight = Std.parseInt(value);
					case 'base': base = Std.parseInt(value);
					case 'scaleW': scaleW = Std.parseInt(value);
					case 'scaleH': scaleH = Std.parseInt(value);
					case 'pages': pages = Std.parseInt(value);
					case 'packed': packed = value != '0';
					case 'alphaChnl': alphaChnl = Std.parseInt(value);
					case 'redChnl': redChnl = Std.parseInt(value);
					case 'greenChnl': greenChnl = Std.parseInt(value);
					case 'blueChnl': blueChnl = Std.parseInt(value);
				}
			}
		);
		
		return
		{
			lineHeight : lineHeight,
			base : base,
			scaleW : scaleW,
			scaleH : scaleH,
			pages : pages,
			packed : packed,
			alphaChnl : alphaChnl,
			redChnl : redChnl,
			greenChnl : greenChnl,
			blueChnl : blueChnl
		};
	}
	
	static function fromBytes(bytes:BytesInput):BMFontCommon
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
			packed: (bytes.readByte() & 0x2) != 0,
			alphaChnl: bytes.readByte(),
			redChnl: bytes.readByte(),
			greenChnl: bytes.readByte(),
			blueChnl: bytes.readByte(),
		};
	}
}