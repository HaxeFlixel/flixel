package flixel.ui;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxImageFrame;
import flixel.input.IFlxInput;
import flixel.text.FlxText;
import flixel.ui.FlxButton.FlxTypedButton;
import openfl.display.BitmapData;

/**
 * A simple button class that calls a function when clicked by the mouse.
 */
class FlxSpriteButton extends FlxTypedButton<FlxSprite> implements IFlxInput
{
	/**
	 * Creates a new FlxButton object with a gray background
	 * and a callback function on the UI thread.
	 *
	 * @param   X         The x position of the button.
	 * @param   Y         The y position of the button.
	 * @param   Text      The text that you want to appear on the button.
	 * @param   OnClick   The function to call whenever the button is clicked.
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Label:FlxSprite, ?OnClick:Void->Void)
	{
		super(X, Y, OnClick);

		for (point in labelOffsets)
			point.set(point.x - 1, point.y + 4);

		label = Label;
	}

	/**
	 * Generates text graphic for button's label.
	 *
	 * @param   Text    text for button's label
	 * @param   font    font name for button's label
	 * @param   size    font size for button's label
	 * @param   color   text color for button's label
	 * @param   align   text align for button's label
	 * @return  this button with generated text graphic.
	 */
	public function createTextLabel(Text:String, ?font:String, size:Int = 8, color:Int = 0x333333, align:String = "center"):FlxSpriteButton
	{
		if (Text != null)
		{
			var text:FlxText = new FlxText(0, 0, frameWidth, Text);
			text.setFormat(font, size, color, align);
			text.alpha = labelAlphas[status];
			text.drawFrame(true);
			var labelBitmap:BitmapData = text.graphic.bitmap.clone();
			var labelKey:String = text.graphic.key;
			text.destroy();

			if (label == null)
				label = new FlxSprite();

			var labelGraphic:FlxGraphic = FlxG.bitmap.add(labelBitmap, false, labelKey);
			label.frames = FlxImageFrame.fromGraphic(labelGraphic);
		}

		return this;
	}
}
