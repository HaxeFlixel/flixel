import flash.text.Font;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.U;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUIRadioGroup;
import flixel.addons.ui.FlxUIInputText;
import flixel.text.FlxText;
import firetongue.FireTongue;
import openfl.Assets;

/**
 * @author Lars Doucet
 */
class State_Title extends FlxUIState
{
	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff131c1b;
		FlxG.log.redirectTraces = false; 
		FlxG.mouse.show();		
		
		if (Main.tongue == null) {
			Main.tongue = new FireTongueEx();
			Main.tongue.init("en-US");
			FlxUIState.static_tongue = Main.tongue;
		}
		
		_xml_id = "state_title";
		//_tongue = Main.tongue;		
		
		super.create();	
	}
	
	public override function getEvent(id:String, sender:Dynamic, data:Dynamic):Void {
		var str:String = "";
		
		switch(id) {
			case "finish_load":
				var radio:FlxUIRadioGroup = cast _ui.getAsset("locale_radio");
				if(radio != null){
					radio.selectedId = Main.tongue.locale.toLowerCase();
				}
			case "click_button":
				if (Std.is(data, Array) && data != null && data.length > 0) {
					switch(cast(data[0],String)) {
						case "saves": FlxG.switchState(new State_SaveMenu());
						case "menu": FlxG.switchState(new State_TestMenu());
						case "battle": FlxG.switchState(new State_Battle());
						case "default_test": FlxG.switchState(new State_DefaultTest());
						case "code_test": FlxG.switchState(new State_CodeTest());
					}
				}
			case "click_radio_group":
				if (Std.is(data, Array) && data != null && data.length > 0) {
					var id:String = ""; if(data[0] != null){ id = cast(data[0], String);}
					var value:String = ""; if(data[1] != null){value = cast(data[1], String);}
					if (value == "checked:true") {
						Main.tongue.init(id, reloadState);
					}
				}
		}		
	}	
	
	private function reloadState():Void {
		FlxG.switchState(new State_Title());
	}
}