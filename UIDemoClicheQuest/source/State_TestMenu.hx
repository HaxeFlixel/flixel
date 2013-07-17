import haxe.xml.Fast;
import nme.Lib;
import flixel.FlxG;
import flixel.addons.ui.FlxStateX;
/**
 * @author Lars Doucet
 */

class State_TestMenu extends FlxStateX
{

	override public function create() 
	{
		_xml_id = "state_menu";
		super.create();
	}
	
	public override function getRequest(id:String, target:Dynamic, data:Dynamic):Dynamic {
		return null;
	}	
	
	public override function getEvent(id:String,target:Dynamic,data:Dynamic):Void {
		if (Std.is(data, String)) {
			switch(cast(data, String)) {
				case "back": FlxG.switchState(new State_Title());
			}
		}
	}
	
	public override function update():Void {
		super.update();
	}
	
}