package;

import flash.Lib;
import flash.events.MouseEvent;
import flash.display.BitmapData;
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
	public function new( X:Int = 0, Y:Int = 0, Label:String, ?Callback:Dynamic, ?Params:Array<Dynamic>, ?Width:Int )
	{
		var wid:Int = 0;
		
		if ( Width == null || Width == 0 )
		{
			wid = Label.length * 7;
		} else {
			wid = Width;
		}
		
		super( X, Y, Label, Callback );
		width = wid;
		height = 20;
		
		loadGraphic( new BitmapData( Std.int( width ), Std.int( height ), true, 0 ) );
		
		label.color = FlxColor.BLACK;
		label.borderStyle = FlxText.BORDER_OUTLINE_FAST;
		label.borderColor = FlxColor.WHITE;
	}
	
	/**
	 * Note that this class overrides FlxButton, but does not call it with super.update() in
	 * this update() function. This is to prevent the automatic alpha variation to the label.
	 * As a consequence, a lot of the stuff from the FlxButton class is repeated here.
	 */
	override public function update():Void
	{
		if (!_initialized)
		{
			if (FlxG.stage != null)
			{
				#if !FLX_NO_MOUSE
					Lib.current.stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
				#end
				_initialized = true;
			}
		}
		
		updateButton(); //Basic button logic
		
		switch ( status ) {
			case FlxButton.HIGHLIGHT:
				label.color = FlxColor.WHITE;
				label.borderStyle = FlxText.BORDER_OUTLINE_FAST;
				label.borderColor = FlxColor.BLACK;
			case FlxButton.PRESSED:
				label.y++;
			default:
				label.color = FlxColor.BLACK;
				label.borderStyle = FlxText.BORDER_OUTLINE_FAST;
				label.borderColor = FlxColor.WHITE;
		}
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