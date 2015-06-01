package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	
	public var text1:FlxText;
	public var text2:FlxText;
	
	override public function create():Void
	{
		super.create();
		
		var format1 = new FlxTextFormat(0xE6E600, false, false, 0xFF8000);
		var format2 = new FlxTextFormat(0xFFAE5E, false, false, 0xFF8000);
		var format3 = new FlxTextFormat(0x008040, false, false, null);
		var format4 = new FlxTextFormat(0x0080C0, false, false, null);
		var format5 = new FlxTextFormat(0x00E6E6, false, false, null);
		var format6 = new FlxTextFormat(0x0080FF, false, false, 0xFFFFFF);
		
		text1 = createText(40, "Formatted via addFormat()");
		text1.addFormat(format1, 0, 5);
		text1.addFormat(format2, 5, 10);
		text1.addFormat(format3, 10, 11);
		text1.addFormat(format4, 11, 12);
		text1.addFormat(format5, 12, 13);
		text1.addFormat(format6, 17, 100);
		add(text1);
		
		text2 = createText(120);
		text2.applyMarkup("*Forma*_tted_ $v$^i^!a! apply:Markup():", [
			new FlxTextFormatMarkerPair(format1, "*"),
			new FlxTextFormatMarkerPair(format2, "_"),
			new FlxTextFormatMarkerPair(format3, "$"),
			new FlxTextFormatMarkerPair(format4, "^"),
			new FlxTextFormatMarkerPair(format5, "!"),
			new FlxTextFormatMarkerPair(format6, ":")]);
		add(text2);
	}
	
	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ONE)
		{
			var b = text1.graphic;
			add(new FlxSprite(0, 0, b));
		}
	}
	
	function createText(y:Float, ?text:String)
	{
		var text = new FlxText(60, y, FlxG.width, text);
		text.setFormat(null, 24, FlxColor.BLACK);
		text.setBorderStyle(OUTLINE, FlxColor.WHITE, 2);
		return text;
	}
}