package;

import org.flixel.plugin.photonstorm.FlxButtonPlus;
import org.flixel.FlxG;

class R 
{
	static public var GS:GameState;
	
	static public function modifyButton(B:FlxButtonPlus, Width:Int = 70):Void
	{
		B.textNormal.color = FlxG.BLACK;
		B.textHighlight.color = 0xFF808080 ;
		B.buttonHighlight.makeGraphic(Width, 20, 0);
		B.buttonNormal.makeGraphic(Width, 20, 0);
		B.textNormal.width = FlxG.width;
		B.textHighlight.width = FlxG.width;
		B.textHighlight.visible = false;
	}
}