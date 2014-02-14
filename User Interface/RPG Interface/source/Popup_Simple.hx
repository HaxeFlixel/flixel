import flixel.addons.ui.FlxUIPopup;

class Popup_Simple extends FlxUIPopup
{
	public override function create():Void
	{
		_xml_id = "popup_simple";
		super.create();
		_ui.setMode("demo");
	}
	
	public override function getEvent(id:String, target:Dynamic, data:Array<Dynamic>, ?params:Array<Dynamic>):Void 
	{
		if (params != null) {
			if (id == "click_button"){
				switch(Std.int(params[0])) {
					case 0: close();
				}
			}
		}
	}
}