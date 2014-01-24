package;

import flash.Lib;
import flash.events.MouseEvent;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;

class Button extends FlxButton
{
	/**
	 * Create a new minimalist button that has black and white text and no background.
	 * 
	 * @param	X			The X position of the button.
	 * @param	Y			The Y position of the button.
	 * @param	Label		The text for this button to display.
	 * @param	?Callback	An optional function to call when the button is clicked.
	 * @param	?Params		Optional parameters to pass to the callback function.
	 * @param	?Width		The width of this button. By default, it's set to seven times the length of the label string.
	 */
	public function new( X:Int = 0, Y:Int = 0, Label:String, ?Callback:Dynamic, ?Params:Array<Dynamic>, Width:Int = -1 )
	{
		super( X, Y, Label, Callback, Params );
		
		if (Width > 0) {
			width = Width;
		}
		else {
			width = Label.length * 7;
		}
		height = 20;
		label.alpha = 1;
		set_status(status);
		
		makeGraphic( Std.int( width ), Std.int( height ), 0 );
	}
	
	/**
	 * Override set_status to change how highlight / normal state looks.
	 */
	override private function set_status(Value:Int):Int
	{
		if (label != null)
		{
			if (Value == FlxButton.HIGHLIGHT)
			{
				#if !mobile // "highlight" doesn't make sense on mobile
				label.color = FlxColor.WHITE;
				label.borderStyle = FlxText.BORDER_OUTLINE_FAST;
				label.borderColor = FlxColor.BLACK;
				#end
			}
			else 
			{
				label.color = FlxColor.BLACK;
				label.borderStyle = FlxText.BORDER_OUTLINE_FAST;
				label.borderColor = FlxColor.WHITE;
			}
		}
		return status = Value;
	}
	
	/**
	 * Just an easy way to get the label text from this button.
	 * Lets you call myButton.text instead of myButton.label.text
	 */
	public var text(get, set):String;
	
	private function get_text():String
	{
		return label.text;
	}
	
	private function set_text( NewText:String ):String
	{
		label.text = NewText;
		
		return label.text;
	}
}