package;

import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUITypedButton;
import flixel.FlxG;

/**
 * @author larsiusprime
 */
class State_Demo2 extends FlxUIState
{
	public function new()
	{
		super();
	}

	override public function create()
	{
		_xml_id = "state_menu_2";
		super.create();
	}

	override public function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		super.getEvent(id, sender, data, params);
		switch (id)
		{
			case FlxUITypedButton.CLICK_EVENT:
				var str:String = (params != null && params.length >= 1) ? cast params[0] : "";
				if (str == "no_defaults")
				{
					FlxG.switchState(new State_Demo());
				}
				if (str == "hand_code")
				{
					FlxG.switchState(new State_DemoCode());
				}
		}
	}
}
