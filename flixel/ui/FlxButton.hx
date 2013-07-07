package flixel.ui;

import flixel.text.FlxText;
import flixel.util.FlxPoint;

class FlxButton extends FlxTypedButton<FlxText>
{
	/**
	 * Used with public variable <code>status</code>, means not highlighted or pressed.
	 */
	inline static public var NORMAL:Int = 0;
	/**
	 * Used with public variable <code>status</code>, means highlighted (usually from mouse over).
	 */
	inline static public var HIGHLIGHT:Int = 1;
	/**
	 * Used with public variable <code>status</code>, means pressed (usually from mouse click).
	 */
	inline static public var PRESSED:Int = 2;
	
	/**
	 * Creates a new <code>FlxButton</code> object with a gray background
	 * and a callback function on the UI thread.
	 * 
	 * @param	X			The X position of the button.
	 * @param	Y			The Y position of the button.
	 * @param	Label		The text that you want to appear on the button.
	 * @param	OnClick		The function to call whenever the button is clicked.
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Dynamic)
	{
		super(X, Y, Label, OnClick);
		
		if (Label != null)
		{
			labelOffset = new FlxPoint( -1, 3);
			label = new FlxText(X + labelOffset.x, Y + labelOffset.y, 80, Label);
			label.setFormat(null, 8, 0x333333, "center");
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
			label.size = label.size;
		}
	}
}