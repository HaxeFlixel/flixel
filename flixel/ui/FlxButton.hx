package flixel.ui;

import flixel.text.FlxText;
import flixel.util.FlxPoint;

/**
 * A simple button class that calls a function when clicked by the mouse.
 */
class FlxButton extends FlxTypedButton<FlxText>
{
	/**
	 * Used with public variable status, means not highlighted or pressed.
	 */
	public static inline var NORMAL:Int = 0;
	/**
	 * Used with public variable status, means highlighted (usually from mouse over).
	 */
	public static inline var HIGHLIGHT:Int = 1;
	/**
	 * Used with public variable status, means pressed (usually from mouse click).
	 */
	public static inline var PRESSED:Int = 2;
	
	/**
	 * Creates a new FlxButton object with a gray background
	 * and a callback function on the UI thread.
	 * 
	 * @param	X				The X position of the button.
	 * @param	Y				The Y position of the button.
	 * @param	Label			The text that you want to appear on the button.
	 * @param	OnClick			The function to call whenever the button is clicked.
	 * @param	OnClickParams	The params to call the onClick function with.
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Void->Void)
	{
		super(X, Y, Label, OnClick);
		
		if (Label != null)
		{
			for (point in labelOffsets)
			{
				point.set(point.x -1, point.y + 3);
			}
			label = new FlxText(X + labelOffsets[NORMAL].x, Y + labelOffsets[NORMAL].y, 80, Label);
			label.setFormat(null, 8, 0x333333, "center");
			label.alpha = labelAlphas[status];
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
			label.width = label.frameWidth = Std.int(width);
			label.size = label.size; // Calls set_size(), don't remove!
		}
	}
}