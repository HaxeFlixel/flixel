package ;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIText;
import flixel.FlxG;

/**
 * ...
 * @author larsiusprime
 */
class MenuStateB extends MenuState
{

	public function new() 
	{
		super();
	}
	
	private override function init():Void {
		super.init();
		var back:FlxUISprite = cast _ui.getAsset("back");
		back.makeGraphic(FlxG.width, FlxG.height, 0xFF0000AA);
		var welcome:FlxUIText = cast _ui.getAsset("welcome");
		welcome.text = "STATE B";
	}
	
	private override function transition():Void {
		FlxG.switchState(new MenuState());
	}
}