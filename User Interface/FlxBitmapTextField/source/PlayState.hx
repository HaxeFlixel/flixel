package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxBitmapTextField;
import flixel.text.pxText.PxBitmapFont;
import flixel.text.pxText.PxTextAlign;
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
		
		var font:PxBitmapFont = new PxBitmapFont().loadPixelizer(Assets.getBitmapData("assets/fontData10pt.png"), " !\"#$%&'()*+,-./" + "0123456789:;<=>?" + "@ABCDEFGHIJKLMNO" + "PQRSTUVWXYZ[]^_" + "abcdefghijklmno" + "pqrstuvwxyz{|}~\\");
		
		var textBytes = Assets.getText("assets/NavTitle.fnt");
		var XMLData = Xml.parse(textBytes);
		var font2:PxBitmapFont = new PxBitmapFont().loadAngelCode(Assets.getBitmapData("assets/NavTitle.png"), XMLData);
		
		tf = new FlxBitmapTextField(font);
		tf.text = "Hello World!\nand this is\nmultiline!!!";
		tf.color = 0xffffff;
		tf.fixedWidth = false;
		tf.multiLine = true;
		tf.alignment = PxTextAlign.LEFT;
		tf.lineSpacing = 5;
		tf.padding = 5;
		add(tf);
		
	
		tf2 = new FlxBitmapTextField(font2);
		tf2.y = 100;
		tf2.useTextColor = false;
		tf2.text = "Hello World!\nand this is\nmultiline!!!";
		tf2.shadow = true;
		tf2.outlineColor = 0xff0000;
		tf2.width = 610;
		tf2.alignment = PxTextAlign.CENTER;
		tf2.lineSpacing = 5;
		tf2.padding = 20;
		tf2.letterSpacing = 25;
		tf2.autoUpperCase = true;
		tf2.multiLine = true;
		tf2.wordWrap = false;
		tf2.fixedWidth = false;
		add(tf2);
	}
	
	override public function update():Void
	{
		tf.text = "mouseX = " + Math.floor(FlxG.mouse.x) + "\n" + "mouseY = " + Math.floor(FlxG.mouse.y);
		
		super.update();	
	}	
}