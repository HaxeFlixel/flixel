package flixel.graphics.frames.bmfontutils;

typedef BMFontInfoBlock =
{
	public var fontSize:Null<Int>;
	public var smooth:Bool;
	public var unicode:Bool;
	public var italic:Bool;
	public var bold:Bool;
	public var fixedHeight:Bool;
	public var charSet:String;
	public var stretchH:Null<Int>;
	public var aa:Null<Int>;
	public var paddingUp:Null<Int>;
	public var paddingRight:Null<Int>;
	public var paddingDown:Null<Int>;
	public var paddingLeft:Null<Int>;
	public var spacingHoriz:Null<Int>;
	public var spacingVert:Null<Int>;
	public var outline:Null<Int>;
	public var fontName:String;
};

typedef BMFontCommonBlock =
{
	public var lineHeight:Null<Int>;
	public var base:Null<Int>;
	public var scaleW:Null<Int>;
	public var scaleH:Null<Int>;
	public var pages:Null<Int>;
	public var isPacked:Bool;
	public var alphaChnl:Null<Int>;
	public var redChnl:Null<Int>;
	public var greenChnl:Null<Int>;
	public var blueChnl:Null<Int>;
};

typedef BMFontPageInfoBlock =
{
	public var id:Null<Int>;
	public var file:String;
};

typedef BMFontCharBlock =
{
	public var id:Null<Int>;
	public var x:Null<Int>;
	public var y:Null<Int>;
	public var width:Null<Int>;
	public var height:Null<Int>;
	public var xoffset:Null<Int>;
	public var yoffset:Null<Int>;
	public var xadvance:Null<Int>;
	public var page:Null<Int>;
	public var chnl:Null<Int>;
};

typedef BMFontKerningPair =
{
	public var first:Null<Int>;
	public var second:Null<Int>;
	public var amount:Null<Int>;
};

class BMFont
{
	public var info:BMFontInfoBlock;
	public var common:BMFontCommonBlock;
	public var pages:Array<BMFontPageInfoBlock>;
	public var chars:Array<BMFontCharBlock>;
	public var kerningPairs:Array<BMFontKerningPair>;
	
	function new()
	{
		info = {
			fontSize: null,
			smooth: false,
			unicode: false,
			italic: false,
			bold: false,
			fixedHeight: false,
			charSet: null,
			stretchH: null,
			aa: null,
			paddingUp: null,
			paddingRight: null,
			paddingDown: null,
			paddingLeft: null,
			spacingHoriz: null,
			spacingVert: null,
			outline: null,
			fontName: '',
		};
		common = {
			lineHeight: null,
			base: null,
			scaleW: null,
			scaleH: null,
			pages: null,
			isPacked: false,
			alphaChnl: null,
			redChnl: null,
			greenChnl: null,
			blueChnl: null,
		};
		pages = [];
		chars = [];
		kerningPairs = [];
	}
}