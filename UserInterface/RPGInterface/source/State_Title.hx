import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUIRadioGroup;

/**
 * @author Lars Doucet
 */
class State_Title extends FlxUIState
{
	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff131c1b;
		
		if (Main.tongue == null)
		{
			Main.tongue = new FireTongueEx();
			Main.tongue.init("en-US");
			FlxUIState.static_tongue = Main.tongue;
		}
		
		_xml_id = "state_title";
		
		super.create();
	}
	
	public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		switch (name)
		{
			case "finish_load":
				var radio:FlxUIRadioGroup = cast _ui.getAsset("locale_radio");
				if (radio != null && Main.tongue != null)
				{
					radio.selectedId = Main.tongue.locale.toLowerCase();
				}
			case "click_button":
				if (params != null && params.length > 0)
				{
					switch (Std.string(params[0]))
					{
						case "saves": FlxG.switchState(new State_SaveMenu());
						case "menu": FlxG.switchState(new State_TestMenu());
						case "battle": FlxG.switchState(new State_Battle());
						case "default_test": FlxG.switchState(new State_DefaultTest());
						case "code_test": FlxG.switchState(new State_CodeTest());
						case "popup": openSubState(new Popup_Demo());
					}
				}
			case "click_radio_group":
				var id:String = cast data;
				if (Main.tongue != null)
				{
					Main.tongue.init(id, reloadState);
				}
		}
	}
	
	private function reloadState():Void
	{
		FlxG.switchState(new State_Title());
	}
}