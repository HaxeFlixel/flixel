package;

import flixel.ui.FlxButton;

class Button extends FlxButton
{
	override public function new( X:Int, Y:Int, Label:String, Callback:Dynamic )
	{
		super( X, Y, Label, Callback );
		
		makeGraphic( Std.int( width ), Std.int( height ), Reg.MED_LITE );
		label.color = Reg.MED_DARK;
	}
}