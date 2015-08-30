import flixel.addons.ui.Anchor;
import flixel.addons.ui.BorderDef;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUITooltip;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FontDef;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.xml.Fast;
import flash.Lib;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import openfl.Assets;
import openfl.text.TextFormat;
import flixel.text.FlxText.FlxTextBorderStyle;
import openfl.text.TextFormatAlign;
/**
 * @author Lars Doucet
 */

class State_DemoCode extends FlxUIState
{
	public function new()
	{
		super();
	}
	
	override public function create() 
	{
		super.create();
		makeByHand();
	}
	
	override public function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void 
	{
		super.getEvent(id, sender, data, params);
		switch(id)
		{
			case FlxUITypedButton.CLICK_EVENT: 
				var str:String = (params != null && params.length >= 1) ? cast params[0] : "";
				if (str == "defaults")
				{
					FlxG.switchState(new State_Demo2());
				}
				if (str == "no_defaults")
				{
					FlxG.switchState(new State_Demo());
				}
		}
	}
	
	private function makeFontDef(name:String, size:Int, alignment = null, isBold:Bool = true, color:FlxColor = FlxColor.WHITE, extension:String = ".ttf"):FontDef
	{
		var suffix:String = isBold ? "b" : "";
		return new FontDef(name, extension, "assets/fonts/" + name + suffix + extension, new TextFormat(null, size, color, isBold, null, null, null, null, alignment));
	}
	
	private function makeByHand():Void
	{
		_ui.addAsset(cast new FlxUISprite().makeGraphic(FlxG.width, FlxG.height, 0xFF404040), "bkg");
		
		var border  = new BorderDef(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
		var sans8   = makeFontDef("vera", 8);
		var sans10  = makeFontDef("vera", 10);
		var sans10c = makeFontDef("vera", 10, TextFormatAlign.CENTER);
		var sans12  = makeFontDef("vera", 12);
		var sans16  = makeFontDef("vera", 16);
		var sans16c = makeFontDef("vera", 16, TextFormatAlign.CENTER);
		
		var t = null;
		t = addTxt("txt0", new FlxUIText(100,  75, 200, "Tooltips 101"), sans16c, border);
		t = addTxt("txt1", new FlxUIText(100, 100, 200, "Mouse over the buttons"), sans10c, border);
		
		var b = null;
		b = addBtn("basic", new FlxUIButton(160, 120, "Basic"), "Basic tooltip");
		
		b = addBtn(
			"fancier", new FlxUIButton(b.x, b.y + b.height + 10, "Fancier"), 
			"Fancier tooltip!", 
			"This tooltip has a title AND a body.", 
			null, 
			{ bodyWidth:100 } );
			
		b = addBtn(
			"even_fancier", new FlxUIButton(b.x, b.y + b.height + 10, "Even fancier"), 
			"Even fancier tooltip!", 
			"This tooltip has a title and a body, as well as custom padding and offsets", 
			null, 
			{ titleWidth:120, bodyWidth:120, bodyOffset:new FlxPoint(5, 5) } );
			
		b = addBtn(
			"fanciest", new FlxUIButton(b.x, b.y + b.height + 10, "Fanciest"),
			"Fanciest tooltip",
			"This tooltip has a title and a body, custom padding and offsets, as well as custom text formatting",
			null,
			{ 
				titleWidth:125, 
				bodyWidth:120, 
				bodyOffset:new FlxPoint(5, 5), 
				titleFormat:sans12, 
				bodyFormat:sans10, 
				titleBorder:border, 
				bodyBorder:border, 
				leftPadding:5, 
				rightPadding:5, 
				topPadding:5, 
				bottomPadding:5, 
				background:FlxColor.RED, 
				borderSize:1, 
				borderColor:FlxColor.WHITE
			} );
			
		b = addBtn(
			"goback", 
			new FlxUIButton(b.x, b.y + b.height + 10, "Go Back", 
				function(){
					FlxG.switchState(new State_Demo());
				}
			),
			"Go Back",
			"This button takes you back to the first screen" );
	}
	
	private function addBtn(name:String="", b:FlxUIButton, title:String = "", body:String = "", anchor:Anchor = null, style:FlxUITooltipStyle = null):FlxUIButton
	{
		tooltips.add(b, { title:title, body:body, anchor:anchor, style:style } );
		_ui.addAsset(b,name);
		return b;
	}
	
	private function addTxt(name:String="", t:FlxUIText, f:FontDef, b:BorderDef):FlxUIText
	{
		_ui.addAsset(cast b.apply(f.applyFlx(t)),name);
		return t;
	}
}