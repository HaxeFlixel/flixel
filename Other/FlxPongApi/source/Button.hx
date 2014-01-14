package;

import flixel.ui.FlxButton;

class Button extends FlxButton
{
	/**
	 * Creates a very simple button with a visual style matching the rest of FlxPongApi.
	 * 
	 * @param	X
	 * @param	Y
	 * @param	Label
	 * @param	?Callback
	 * @param	Width
	 */
	override public function new( X:Int, Y:Int, Label:String, ?Callback:Dynamic, Width:Int = 80 )
	{
		// It's easier to set up one callback function to handle multiple buttons if you can get the button's label in the callback.
		super( X, Y, Label, Callback, [ Label ]);
		makeGraphic( Width, Std.int( height ), Reg.med_lite );
		label.color = Reg.med_dark;
	}
}