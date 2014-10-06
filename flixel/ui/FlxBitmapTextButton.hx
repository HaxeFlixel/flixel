package flixel.ui;

import flixel.system.FlxAssets;
import flixel.text.FlxBitmapTextField;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.pxText.PxBitmapFont;
import flixel.text.pxText.PxTextAlign;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;

/**
 * A button with a bitmap text field for the label
 */
class FlxBitmapTextButton extends FlxTypedButton<FlxBitmapTextField>
{
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Void->Void)
	{
		super(X, Y, OnClick);
		
		if (Label != null)
		{
			label = new FlxBitmapTextField();
			label.width = 80;
			label.text = Label;
			label.fontScale = 0.7 * 10 / 11;
			label.color = 0xFF333333;
			label.useTextColor = true;
			label.alignment = FlxTextAlign.CENTER;
			
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
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (label != null)
		{
			label.update(elapsed);
		}
	}
}