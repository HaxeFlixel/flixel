package flixel.graphics.frames.bmfont;

import haxe.io.BytesInput;

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
	/** font name */
	public var face:String;
	public var size:Int;
	public var bold:Bool;
	public var italic:Bool;
	public var charset:String;
	public var unicode:Bool;
	public var stretchH:Int;
	public var smooth:Bool;
	public var aa:Int;
	public var padding:BMFontPadding = {};
	public var spacing:BMFontSpacing = {};
	public var outline:Int = 0;
	public var fixedHeight:Bool = false;
	
	static function fromXml(infoNode:BMFontXml):BMFontInfo
	{
		return {
			face: infoNode.att.string("face"),
			size: infoNode.att.int("size"),
			bold: infoNode.att.boolSafe("bold", false),
			italic: infoNode.att.boolSafe("italic", false),
			smooth: infoNode.att.boolSafe("smooth", false),
			charset: infoNode.att.stringWarn("charset"),
			unicode: infoNode.att.boolWarn("unicode", false),
			stretchH: infoNode.att.intWarn("stretchH", 100),
			aa: infoNode.att.intWarn("aa", 1),
			padding: BMFontPadding.fromString(infoNode.att.stringWarn("padding")),
			spacing: BMFontSpacing.fromString(infoNode.att.stringWarn("spacing")),
			outline: infoNode.att.intSafe("outline", 0),
			fixedHeight: infoNode.att.boolSafe("fixedHeight", false)
		}
	}
	
	static function fromText(infoText:String):BMFontInfo
	{
		var face:String = null;
		var size = -1;
		var bold = false;
		var italic = false;
		var smooth = false;
		var charset:String = null;
		var unicode = false;
		var stretchH = 100;
		var aa = 1;
		var padding = new BMFontPadding();
		var spacing = new BMFontSpacing();
		var outline = 0;
		var fixedHeight = false;
		
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
					case 'padding': padding = BMFontPadding.fromString(value);
					case 'spacing': spacing = BMFontSpacing.fromString(value);
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
			padding: padding,
			spacing: spacing,
			outline: outline,
			fixedHeight: fixedHeight
		};
	}
	
	static function fromBytes(bytes:BytesInput)
	{
		final blockSize = bytes.readInt32();
		final size = bytes.readInt16();
		final bitField = bytes.readByte();
		final charsetByte = bytes.readByte();
		final fontInfo:BMFontInfo =
		{
			size: size,
			smooth: (bitField & 0x80) != 0,
			unicode: (bitField & (0x80 >> 1)) != 0,
			italic: (bitField & (0x80 >> 2)) != 0,
			bold: (bitField & (0x80 >> 3)) != 0,
			fixedHeight: (bitField & (0x80 >> 4)) != 0,
			charset: charsetByte > 0 ? String.fromCharCode(charsetByte) : "",
			stretchH: bytes.readUInt16(),
			aa: bytes.readByte(),
			padding: BMFontPadding.fromBytes(new BytesInput(bytes.read(4))),
			spacing: BMFontSpacing.fromBytes(new BytesInput(bytes.read(2))),
			outline: bytes.readByte(),
			face: bytes.readString(blockSize - 14 - 1)
		};
		bytes.readByte(); // skip the null terminator of the string
		return fontInfo;
	}
}

@:structInit
class BMFontPadding
{
	public var up:Int = 0;
	public var right:Int = 0;
	public var down:Int = 0;
	public var left:Int = 0;
	
	public inline function new(up = 0, right = 0, down = 0, left = 0)
	{
		this.up = up;
		this.right = right;
		this.down = down;
		this.left = left;
	}
	
	public static inline function fromString(data:String):BMFontPadding
	{
		final values = data.split(',');
		return
		{
			up: Std.parseInt(values[0]),
			right: Std.parseInt(values[1]),
			down: Std.parseInt(values[2]),
			left: Std.parseInt(values[3])
		};
	}
	
	public static inline function fromBytes(bytes:BytesInput):BMFontPadding
	{
		return
		{
			up: bytes.readByte(),
			right: bytes.readByte(),
			down: bytes.readByte(),
			left: bytes.readByte()
		};
	}
}

@:structInit
class BMFontSpacing
{
	public var x:Int = 0;
	public var y:Int = 0;
	
	public inline function new(x = 0, y = 0)
	{
		this.x = x;
		this.y = y;
	}
	
	public static function fromString(data:String):BMFontSpacing
	{
		final values = data.split(',');
		return { x: Std.parseInt(values[0]), y: Std.parseInt(values[1]) };
	}
	
	public static inline function fromBytes(bytes:BytesInput):BMFontSpacing
	{
		return { x: bytes.readByte(), y: bytes.readByte() };
	}
}