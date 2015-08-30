package;

import flixel.ui.FlxButton;

class Button extends FlxButton
{
	/**
	 * Creates a very simple button with a visual style matching the rest of FlxPongApi.
	 */
	override public function new(X:Int, Y:Int, Label:String, ?Callback:String->Void, Width:Int = 80)
	{
		// It's easier to set up one callback function to handle multiple buttons if you can get the button's label in the callback.
		super(X, Y, Label, Callback.bind(Label));
		makeGraphic(Width, Std.int(height), Reg.med_lite);
		label.color = Reg.med_dark;
	}
}