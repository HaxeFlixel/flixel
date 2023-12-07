package flixel.graphics.frames.bmfontutils;

typedef BMFontInfoBlock =
{
	public var fontSize:Int;
	public var smooth:Bool;
	public var unicode:Bool;
	public var italic:Bool;
	public var bold:Bool;
	public var fixedHeight:Bool;
	public var charSet:String;
	public var stretchH:Int;
	public var aa:Int;
	public var paddingUp:Int;
	public var paddingRight:Int;
	public var paddingDown:Int;
	public var paddingLeft:Int;
	public var spacingHoriz:Int;
	public var spacingVert:Int;
	public var outline:Int;
	public var fontName:String;
};

typedef BMFontCommonBlock =
{
	public var lineHeight:Int;
	public var base:Int;
	public var scaleW:Int;
	public var scaleH:Int;
	public var pages:Int;
	public var isPacked:Bool;
	public var alphaChnl:Int;
	public var redChnl:Int;
	public var greenChnl:Int;
	public var blueChnl:Int;
};

typedef BMFontPageInfoBlock =
{
	public var id:Int;
	public var file:String;
};

typedef BMFontCharBlock =
{
	public var id:Int;
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var xoffset:Int;
	public var yoffset:Int;
	public var xadvance:Int;
	public var page:Int;
	public var chnl:Int;
};

typedef BMFontKerningPair =
{
	public var first:Int;
	public var second:Int;
	public var amount:Int;
};

class BMFont
{
	public var info:BMFontInfoBlock;
	public var common:BMFontCommonBlock;
	public var pages:Array<BMFontPageInfoBlock>;
	public var chars:Array<BMFontCharBlock>;
	public var kerningPairs:Array<BMFontKerningPair>;
	// convenient way of initializing the structs without having to fill in defaults all the time
	public static inline function getDefaultInfoBlock():BMFontInfoBlock
	{
		return {
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
			fontName: '',
		};
	}
	
	public static inline function getDefaultCommonBlock():BMFontCommonBlock
	{
		return {
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
	
	public static inline function getDefaultPageBlock():BMFontPageInfoBlock
	{
		return {
			id: -1,
			file: ''
		};
	}
	
	public static inline function getDefaultCharBlock():BMFontCharBlock
	{
		return {
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
		};
	}
	
	public static inline function getDefaultKerningPair():BMFontKerningPair
	{
		return {
			first: -1,
			second: -1,
			amount: 0
		};
	}
	
	function new()
	{
		info = getDefaultInfoBlock();
		common = getDefaultCommonBlock();
		pages = [];
		chars = [];
		kerningPairs = [];
	}
}