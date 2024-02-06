package flixel.graphics.frames.bmfont;

import haxe.io.BytesInput;

/**
 * Common data used internally via `FlxBitmapFont.fromAngelCode` to serialize text, xml or binary
 * files exported from [BMFont](https://www.angelcode.com/products/bmfont/)
 * 
 * @since 5.6.0
 * @see [flixel.graphics.frames.FlxBitmapFont.fromAngelCode](https://api.haxeflixel.com/flixel/graphics/frames/FlxBitmapFont.html#fromAngelCode)
 */
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
	
	static function fromXml(commonNode:BMFontXml):BMFontCommon
	{
		return
		{
			lineHeight: commonNode.att.int("lineHeight"),
			base: commonNode.att.intWarn("base", -1),
			scaleW: commonNode.att.intWarn("scaleW", 1),
			scaleH: commonNode.att.intWarn("scaleH", 1),
			pages: commonNode.att.intSafe("pages", 0),
			packed: commonNode.att.boolSafe("packed", false),
			alphaChnl: commonNode.att.intSafe("alphaChnl", 0),
			redChnl: commonNode.att.intSafe("redChnl", 0),
			greenChnl: commonNode.att.intSafe("greenChnl", 0),
			blueChnl: commonNode.att.intSafe("blueChnl", 0)
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
		var alphaChnl:Int = 0;
		var redChnl:Int = 0;
		var greenChnl:Int = 0;
		var blueChnl:Int = 0;
		
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