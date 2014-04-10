import flixel.addons.ui.FlxUIButton;
import haxe.xml.Fast;
import flash.Lib;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
/**
 * @author Lars Doucet
 */

class State_TestMenu extends FlxUIState
{

	override public function create() 
	{
		_xml_id = "state_menu";
		super.create();
	}
	
	public override function getRequest(name:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Dynamic {
		return null;
	}	
	
	public override function getEvent(name:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (params != null){
			switch(name) {
				case "click_button":
					switch(cast(params[0], String)) {
						case "back": FlxG.switchState(new State_Title());
					}
			}
		}
	}
	
	public override function update():Void {
		super.update();
	}
	
}