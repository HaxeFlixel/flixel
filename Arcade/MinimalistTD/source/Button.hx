package;

import flixel.util.FlxColor;
import flixel.ui.FlxButton;

class Button extends FlxButton
{
	/**
	 * Create a new minimalist button that has black and white text and no background.
	 *
	 * @param	X		The X position of the button.
	 * @param	Y		The Y position of the button.
	 * @param	Label	The text for this button to display.
	 * @param	OnDown	An optional function to call when the button is clicked.
	 * @param	Width	The width of this button. By default, it's set to seven times the length of the label string.
	 */
	public function new(X:Int = 0, Y:Int = 0, Label:String, ?OnDown:Void->Void, Width:Int = -1)
	{
		super(X, Y, Label, OnDown);

		if (Width > 0)
			width = Width;
		else
			width = Label.length * 7;
		height = 20;
		label.alpha = 1;
		set_status(status);

		makeGraphic(Std.int(width), Std.int(height), 0);
	}

	/**
	 * Override set_status to change how highlight / normal state looks.
	 */
	override function set_status(Value:Int):Int
	{
		if (label != null)
		{
			if (Value == FlxButton.HIGHLIGHT)
			{
				#if !mobile // "highlight" doesn't make sense on mobile
				label.color = FlxColor.WHITE;
				label.borderStyle = OUTLINE_FAST;
				label.borderColor = FlxColor.BLACK;
				#end
			}
			else
			{
				label.color = FlxColor.BLACK;
				label.borderStyle = OUTLINE_FAST;
				label.borderColor = FlxColor.WHITE;
			}
		}
		return status = Value;
	}
}
