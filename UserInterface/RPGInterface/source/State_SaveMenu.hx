import flixel.FlxG;
import flixel.addons.ui.FlxUIState;

using flixel.util.FlxStringUtil;

#if haxe4
import haxe.xml.Access;
#else
import haxe.xml.Fast as Access;
#end

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

	override public function getRequest(id:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Dynamic
	{
		var xml:Access;
		#if (haxe_ver < "4.0.0")
		if (Std.is(data, Access))
		#else
		if (Std.is(data, Xml))
		#end
		{
			xml = cast data;
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

	override public function getEvent(id:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
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
