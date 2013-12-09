package;

import flixel.addons.ui.FlxButtonPlus;

class Button extends FlxButtonPlus
{
	public function new( X:Int = 0, Y:Int = 0, Label:String, ?Callback:Dynamic, ?Params:Array<Dynamic> )
	{
		var width:Int = Label.length * 7;
		super( X, Y, Callback, Params, Label, width );
		textNormal.color = 0xff000000;
		textHighlight.color = 0xFF808080;
		buttonHighlight.makeGraphic(width, 20, 0);
		buttonNormal.makeGraphic(width, 20, 0);
		textNormal.width = width;
		textHighlight.width = width;
		textHighlight.visible = false;
	}
}