package;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxButtonPlus;

class Button extends FlxButtonPlus
{
	public function new( X:Int = 0, Y:Int = 0, Label:String, ?Callback:Dynamic, ?Params:Array<Dynamic> )
	{
		var width:Int = Label.length * 7;
		super( X, Y, Callback, Params, Label, width, 20 );
		textNormal.color = FlxColor.BLACK;
		textNormal.borderStyle = FlxText.BORDER_OUTLINE;
		textNormal.borderColor = FlxColor.WHITE;
		
		textHighlight.color = FlxColor.WHITE;
		textHighlight.borderStyle = FlxText.BORDER_OUTLINE;
		textHighlight.borderColor = FlxColor.BLACK;
		//textHighlight.color = 0xFF808080;
		buttonHighlight.makeGraphic(width, 20, 0);
		buttonNormal.makeGraphic(width, 20, 0);
		textHighlight.visible = false;
	}
}