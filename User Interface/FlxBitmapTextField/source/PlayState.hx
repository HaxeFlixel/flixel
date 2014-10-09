package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;
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
		var fontXNA:FlxBitmapFont = FlxBitmapFont.fromXNA(Assets.getBitmapData("assets/fontData10pt.png"), letters);
		
		var textBytes = Assets.getText("assets/NavTitle.fnt");
		var XMLData = Xml.parse(textBytes);
		var fontAngelCode:FlxBitmapFont = FlxBitmapFont.fromAngelCode(Assets.getBitmapData("assets/NavTitle.png"), XMLData);
		
		var monospaceLetters:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789?!().,";
		var charSize:FlxPoint = FlxPoint.get(48, 50);
		var fontMonospace:FlxBitmapFont = FlxBitmapFont.fromMonospace(Assets.getBitmapData("assets/260.png"), monospaceLetters, charSize);
		
		tf = new FlxBitmapTextField(fontXNA);
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
		
	
		tf2 = new FlxBitmapTextField(fontAngelCode);
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
		
		var tf3:FlxBitmapTextField = new FlxBitmapTextField(fontMonospace);
		tf3.y = 300;
		tf3.autoUpperCase = true;
		tf3.text = "Robocop rules!!!";
		add(tf3);
	}
	
	override public function update(elapsed:Float):Void
	{
		tf.text = "mouseX = " + Math.floor(FlxG.mouse.x) + "\n" + "mouseY = " + Math.floor(FlxG.mouse.y);
		
		super.update(elapsed);	
	}	
}