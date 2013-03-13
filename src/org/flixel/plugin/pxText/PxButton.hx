package org.flixel.plugin.pxText;

import org.flixel.FlxAssets;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxPoint;

/**
 * A simple button class that calls a function when clicked by the mouse.
 */
class PxButton extends FlxTypedButton<FlxBitmapTextField>
{
	public function new(X:Float = 0, Y:Float = 0, Label:String = null, OnClick:Void->Void = null)
	{
		super(X, Y, Label, OnClick);
		if(Label != null)
		{
			// TODO: redo this
			if (PxBitmapFont.fetch("nokiafc22") == null)
			{
				PxBitmapFont.store("nokiafc22", new PxBitmapFont().loadPixelizer(FlxAssets.getBitmapData("assets/data/fontData11pt.png"), " !\"#$%&'()*+,-./" + "0123456789:;<=>?" + "@ABCDEFGHIJKLMNO" + "PQRSTUVWXYZ[]^_" + "abcdefghijklmno" + "pqrstuvwxyz{|}~\\`"));
			}
			
			label = new FlxBitmapTextField(PxBitmapFont.fetch("nokiafc22"));
			label.setWidth(80);
			label.text = Label;
			label.fontScale = 0.7 * 10 / 11;
			#if !neko
			label.color = 0x333333;
			#else
			label.color = {rgb: 0x333333, a: 0xff};
			#end
			label.useTextColor = false;
			label.alignment = PxTextAlign.CENTER;
			labelOffset = new FlxPoint(0, 5);
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
			label.setWidth(Std.int(width));
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