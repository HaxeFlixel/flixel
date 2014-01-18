package flixel.ui;

import flixel.system.FlxAssets;
import flixel.text.FlxBitmapTextField;
import flixel.text.pxText.PxBitmapFont;
import flixel.text.pxText.PxTextAlign;
import flixel.ui.FlxTypedButton;
import flixel.util.FlxPoint;

/**
 * A button with a bitmap text field for the label
 */
class PxButton extends FlxTypedButton<FlxBitmapTextField>
{
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Dynamic)
	{
		super(X, Y, Label, OnClick);
		
		if (Label != null)
		{
			// TODO: redo this
			if (PxBitmapFont.fetch("nokiafc22") == null)
			{
				PxBitmapFont.store("nokiafc22", new PxBitmapFont().loadPixelizer(FlxAssets.getBitmapData("assets/data/fontData11pt.png"), " !\"#$%&'()*+,-./" + "0123456789:;<=>?" + "@ABCDEFGHIJKLMNO" + "PQRSTUVWXYZ[]^_" + "abcdefghijklmno" + "pqrstuvwxyz{|}~\\`"));
			}
			
			label = new FlxBitmapTextField(PxBitmapFont.fetch("nokiafc22"));
			label.width = 80;
			label.text = Label;
			label.fontScale = 0.7 * 10 / 11;
			label.color = 0x333333;
			label.useTextColor = false;
			label.alignment = PxTextAlign.CENTER;
			
			for (offset in labelOffsets)
			{
				offset.set(0, 5);
			}
			
			label.x = X + labelOffsets[status].x;
			label.y = Y + labelOffsets[status].y;
		}
	}
	
	/**
	 * Updates the size of the text field to match the button.
	 */
	override private function resetHelpers():Void
	{
		super.resetHelpers();
		
		if (label != null)
		{
			label.width = width;
		}
	}
	
	override public function update():Void
	{
		super.update();
		
		if (label != null)
		{
			label.update();
		}
	}
}