package;

import flixel.ui.FlxButton;

class Button extends FlxButton
{
	override public function new( X:Int, Y:Int, Label:String, ?Callback:Dynamic, Width:Int = 80 )
	{
		super( X, Y, Label, Callback );
		makeGraphic( Width, Std.int( height ), Reg.MED_LITE );
		label.color = Reg.MED_DARK;
	}
}