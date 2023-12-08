package flixel.graphics.frames.bmfont;

import haxe.io.BytesInput;
import haxe.xml.Access;

/**
 * Info data used internally via `FlxBitmapFont.fromAngelCode` to serialize text, xml or binary
 * files exported from [BMFont](https://www.angelcode.com/products/bmfont/)
 * 
 * @since 5.6.0
 * @see [flixel.graphics.frames.FlxBitmapFont.fromAngelCode](https://api.haxeflixel.com/flixel/graphics/frames/FlxBitmapFont.html#fromAngelCode)
 */
@:structInit
@:allow(flixel.graphics.frames.bmfont.BMFont)
class BMFontInfo
{
	public var size:Int;
	public var smooth:Bool;
	public var unicode:Bool;
	public var italic:Bool;
	public var bold:Bool;
	public var fixedHeight:Bool;
	public var charset:String;
	public var stretchH:Int;
	public var aa:Int;
	public var paddingUp:Int;
	public var paddingRight:Int;
	public var paddingDown:Int;
	public var paddingLeft:Int;
	public var spacingHoriz:Int;
	public var spacingVert:Int;
	public var outline:Int;
	/** font name */
	public var face:String;
	
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
	
	static function fromXml(infoNode:Access):BMFontInfo
	{
		final paddings = infoNode.att.padding.split(',').map(Std.parseInt);
		final spacings = infoNode.att.spacing.split(',').map(Std.parseInt);
		
		return {
			size: Std.parseInt(infoNode.att.size),
			smooth: infoNode.att.smooth != '0',
			unicode: infoNode.att.unicode != '0',
			italic: infoNode.att.italic != '0',
			bold: infoNode.att.bold != '0',
			fixedHeight: infoNode.has.fixedHeight && infoNode.att.fixedHeight != '0',
			charset: infoNode.att.charset,
			stretchH: Std.parseInt(infoNode.att.stretchH),
			aa: Std.parseInt(infoNode.att.aa),
			paddingUp: paddings[0],
			paddingRight: paddings[1],
			paddingDown: paddings[2],
			paddingLeft: paddings[3],
			spacingHoriz: spacings[0],
			spacingVert: spacings[1],
			outline: infoNode.has.outline ? Std.parseInt(infoNode.att.outline) : 0,
			face: infoNode.att.face
		}
	}
	
	static function fromText(infoText:String):BMFontInfo
	{
		var size = -1;
		var smooth = false;
		var unicode = false;
		var italic = false;
		var bold = false;
		var fixedHeight = false;
		var charset:String = null;
		var stretchH = 100;
		var aa = 1;
		var paddings:Array<Int> = [0, 0, 0, 0];
		var spacings:Array<Int> = [0, 0];
		var outline = 0;
		var face = null;
		
		BMFontUtil.forEachAttribute(infoText,
			function(key:String, value:String)
			{
				switch key
				{
					case 'face': face = value;
					case 'size': size = Std.parseInt(value);
					case 'bold': bold = value != '0';
					case 'italic': italic = value != '0';
					case 'charset': charset = value;
					case 'unicode': unicode = value != '0';
					case 'stretchH': stretchH = Std.parseInt(value);
					case 'smooth': smooth = value != '0';
					case 'aa': aa = Std.parseInt(value);
					case 'padding': paddings = value.split(',').map(Std.parseInt);
					case 'spacing': spacings = value.split(',').map(Std.parseInt);
					case 'outline': outline = Std.parseInt(value);
					case 'fixedHeight': fixedHeight = value != '0';
				}
			}
		);
		
		return
		{
			face: face,
			size: size,
			bold: bold,
			italic: italic,
			charset: charset,
			unicode: unicode,
			stretchH: stretchH,
			smooth: smooth,
			aa: aa,
			paddingUp: paddings[0],
			paddingRight: paddings[1],
			paddingDown: paddings[2],
			paddingLeft: paddings[3],
			spacingHoriz: spacings[0],
			spacingVert: spacings[1],
			outline: outline,
			fixedHeight: fixedHeight
		};
	}
	
	static function fromBytes(bytes:BytesInput)
	{
		final blockSize = bytes.readInt32();
		final bitField = bytes.readByte();
		final fontInfo:BMFontInfo =
		{
			size: bytes.readInt16(),
			smooth: (bitField & 0x80) != 0,
			unicode: (bitField & (0x80 >> 1)) != 0,
			italic: (bitField & (0x80 >> 2)) != 0,
			bold: (bitField & (0x80 >> 3)) != 0,
			fixedHeight: (bitField & (0x80 >> 4)) != 0,
			charset: String.fromCharCode(bytes.readByte()),
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