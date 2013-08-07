import flash.text.Font;
import flixel.FlxG;
import flixel.addons.ui.FlxStateX;
import flixel.addons.ui.FlxRadioGroup;
import flixel.addons.ui.FlxInputText;
import flixel.text.FlxText;
import firetongue.FireTongue;
import openfl.Assets;

/**
 * @author Lars Doucet
 */

class State_Title extends FlxStateX
{
	
	
	override public function create():Void
	{
		#if !neko
		FlxG.cameras.bgColor = 0xff131c1b;
		#else
		FlxG.cameras.bgColor = {rgb: 0x131c1b, a: 0xff};
		#end		
		
		FlxG.log.redirectTraces = false;
		FlxG.mouse.show();		
		//FlxG.mouse.useSystemCursor = true;
	
		if (Main.tongue == null) {
			Main.tongue = new FireTongueEx();
			Main.tongue.init("en-US");
			FlxStateX.static_tongue = Main.tongue;
		}
		
		_xml_id = "state_title";
		_tongue = Main.tongue;		
		super.create();	
	}
	
	public override function getEvent(id:String, sender:Dynamic, data:Dynamic):Void {
		var str:String = "";
		
		switch(id) {
			case "finish_load":
				var radio:FlxRadioGroup = cast _ui.getAsset("locale_radio");
				radio.selectedId = Main.tongue.locale.toLowerCase();
			case "click_button":
				if (Std.is(data, Array) && data != null && data.length > 0) {
					switch(cast(data[0],String)) {
						case "saves": FlxG.switchState(new State_SaveMenu());
						case "menu": FlxG.switchState(new State_TestMenu());
						case "battle": FlxG.switchState(new State_Battle());
					}
				}
			case "click_radio_group":
				if (Std.is(data, Array) && data != null && data.length > 0) {
					var id:String = cast(data[0], String);
					var value:String = cast(data[1], String);
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