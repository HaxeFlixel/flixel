package flixel.ui;

import flixel.input.IFlxInput;
import flixel.ui.FlxButton.FlxTypedButton;

/**
 * A simple button class that calls a function when clicked by the mouse.
 */
class FlxSpriteButton extends FlxTypedButton<FlxSprite> implements IFlxInput
{
	// TODO: update size of label (when it's required) and make it automated
	
	/**
	 * Creates a new FlxButton object with a gray background
	 * and a callback function on the UI thread.
	 * 
	 * @param   X          The x position of the button.
	 * @param   Y          The y position of the button.
	 * @param   Text       The text that you want to appear on the button.
	 * @param   OnClick    The function to call whenever the button is clicked.
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Label:FlxSprite, ?OnClick:Void->Void)
	{
		super(X, Y, OnClick);
		
		for (point in labelOffsets)
		{
			point.set(point.x - 1, point.y + 3);
		}
		
		label = Label;
	}
}