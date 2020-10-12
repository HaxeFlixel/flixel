package flixel.ui;

import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.ui.FlxButton.FlxTypedButton;

/**
 * A button with `FlxBitmapText` field as a `label`.
 */
class FlxBitmapTextButton extends FlxTypedButton<FlxBitmapText>
{
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Void->Void)
	{
		super(X, Y, OnClick);

		if (Label != null)
		{
			label = new FlxBitmapText();
			label.width = 80;
			label.text = Label;
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
	override function resetHelpers():Void
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
