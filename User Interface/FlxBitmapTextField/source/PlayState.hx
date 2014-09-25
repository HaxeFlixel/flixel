package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.frames.BitmapFont;
import flixel.text.FlxBitmapTextField;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;

class PlayState extends FlxState
{
	private var tf:FlxBitmapTextField;
	private var tf2:FlxBitmapTextField;
	
	override public function create():Void
	{
		super.create();
		
		FlxG.camera.bgColor = FlxColor.WHITE;
		
		var letters:String = " !\"#$%&'()*+,-./" + "0123456789:;<=>?" + "@ABCDEFGHIJKLMNO" + "PQRSTUVWXYZ[]^_" + "abcdefghijklmno" + "pqrstuvwxyz{|}~\\";
		var font:BitmapFont = BitmapFont.fromXNA(Assets.getBitmapData("assets/fontData10pt.png"), letters);
		
		var textBytes = Assets.getText("assets/NavTitle.fnt");
		var XMLData = Xml.parse(textBytes);
		var font2:BitmapFont = BitmapFont.fromAngelCode(Assets.getBitmapData("assets/NavTitle.png"), XMLData);
		
		tf = new FlxBitmapTextField(font);
		tf.text = "Hello World!\nand this is\nmultiline!!!";
		tf.textColor = 0xff000000;
		tf.useTextColor = true;
		tf.autoSize = true;
		tf.multiLine = true;
		tf.alignment = FlxTextAlign.LEFT;
		tf.lineSpacing = 5;
		tf.padding = 5;
		tf.background = true;
		tf.backgroundColor = 0xff00ff00;
		add(tf);
		
	
		tf2 = new FlxBitmapTextField(font2);
		tf2.y = 100;
		tf2.useTextColor = false;
		tf2.text = "Hello World!\nand this is\nmultiline!!!";
		tf2.borderStyle = FlxTextBorderStyle.SHADOW;
		tf2.borderColor = 0xffff0000;
		tf2.width = 610;
		tf2.alignment = FlxTextAlign.CENTER;
		tf2.lineSpacing = 5;
		tf2.padding = 20;
		tf2.letterSpacing = 25;
		tf2.autoUpperCase = true;
		tf2.multiLine = true;
		tf2.wordWrap = false;
		tf2.autoSize = true;
		add(tf2);
	}
	
	override public function update(elapsed:Float):Void
	{
		tf.text = "mouseX = " + Math.floor(FlxG.mouse.x) + "\n" + "mouseY = " + Math.floor(FlxG.mouse.y);
		
		super.update(elapsed);	
	}	
}