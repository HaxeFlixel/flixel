import haxe.xml.Fast;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
using flixel.util.FlxStringUtil;

/**
 * ...
 * @author Lars Doucet
 */
class State_SaveMenu extends FlxUIState
{
	override public function create() 
	{
		_xml_id = "state_save";
		super.create();
	}
	
	public override function getRequest(id:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Dynamic
	{
		var xml:Fast;
		if (Std.is(data, Fast))
		{
			xml = cast(data, Fast);
		}
		if (id.indexOf("ui_get:") == 0)
		{
			switch (id.remove("ui_get:"))
			{
				case "save_slot":
					return new SaveSlot(data, _ui);
			}
		}
		return null;
	}
	
	public override function getEvent(id:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		if (params != null)
		{
			switch (id)
			{
			case "click_button":
				switch (Std.string(params[0]))
				{
					case "back": FlxG.switchState(new State_Title());
				}
			}
		}
	}
}