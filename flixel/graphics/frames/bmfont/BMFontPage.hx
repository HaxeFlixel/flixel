package flixel.graphics.frames.bmfont;

import haxe.io.BytesInput;
import haxe.io.BytesBuffer;

/**
 * Page data used internally via `FlxBitmapFont.fromAngelCode` to serialize text, xml or binary
 * files exported from [BMFont](https://www.angelcode.com/products/bmfont/)
 * 
 * @since 5.6.0
 * @see [flixel.graphics.frames.FlxBitmapFont.fromAngelCode](https://api.haxeflixel.com/flixel/graphics/frames/FlxBitmapFont.html#fromAngelCode)
 */
@:structInit
@:allow(flixel.graphics.frames.bmfont.BMFont)
class BMFontPage
{
	public var id:Int;
	public var file:String;
	
	public inline function new(id, file)
	{
		this.id = id;
		this.file = file;
	}
	
	static function fromXml(pageNode:BMFontXml):BMFontPage
	{
		return
		{
			id: pageNode.att.int("id"),
			file: pageNode.att.string("file")
		}
	}
	
	static function listFromXml(pagesNode:BMFontXml):Array<BMFontPage>
	{
		final pages = pagesNode.nodes("page");
		return [for (page in pages) fromXml(page) ];
	}
	
	static function fromText(pageText:String)
	{
		var id = -1;
		var file:String = null;
		BMFontUtil.forEachAttribute(pageText, 
			function(key:String, value:String)
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
	
	static function listFromBytes(bytes:BytesInput)
	{
		var blockSize = bytes.readInt32();
		final pages = new Array<BMFontPage>();
		
		var i = 0;
		while (blockSize > 0)
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