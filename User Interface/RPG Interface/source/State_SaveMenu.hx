import haxe.xml.Fast;
import flash.Lib;
import flixel.FlxG;
import flixel.addons.ui.FlxStateX;

/**
 * ...
 * @author Lars Doucet
 */

class State_SaveMenu extends FlxStateX
{

	override public function create() 
	{
		_xml_id = "state_save";
		super.create();
	}
	
	public override function getRequest(id:String, target:Dynamic, data:Dynamic):Dynamic {
		var xml:Fast;
		if (Std.is(data, Fast)) {
			xml = cast(data, Fast);
		}
		if (id.indexOf("ui_get:") == 0) {
			var str:String = StringTools.replace(id,"ui_get:","");
			switch(str) {
				case "save_slot": 					
					return new SaveSlot(data.data, data.definition, _ui);
			}
		}
		return null;
	}
	
	public override function eventResponse(id:String, target:Dynamic, data:Array<Dynamic>):Void 
	{
		if (data != null) {
			switch(cast(data[0], String)) {
				case "back": FlxG.switchState(new State_Title());
			}
		}
	}
	
	public override function update():Void {
		super.update();
	}
}