package;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;

class Button extends FlxButton
{
	public function new( X:Int = 0, Y:Int = 0, Label:String, ?Callback:Dynamic, ?Params:Array<Dynamic>, ?Width:Int )
	{
		var wid:Int = 0;
		
		if ( Width == null || Width == 0 ) {
			wid = Label.length * 7;
		} else {
			wid = Width;
		}
		
		super( X, Y, Label, Callback );
		width = wid;
		height = 20;
		
		//textNormal.color = FlxColor.BLACK;
		//textNormal.borderStyle = FlxText.BORDER_OUTLINE;
		//textNormal.borderColor = FlxColor.WHITE;
		
		//textHighlight.color = FlxColor.WHITE;
		//textHighlight.borderStyle = FlxText.BORDER_OUTLINE;
		//textHighlight.borderColor = FlxColor.BLACK;
		//textHighlight.color = 0xFF808080;
		//buttonHighlight.makeGraphic(width, 20, 0);
		//buttonNormal.makeGraphic(width, 20, 0);
		//textHighlight.visible = false;
	}
	
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