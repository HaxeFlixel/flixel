import flixel.addons.ui.FlxUIPopup;

/**
 * ...
 * @author 
 */
class Popup_Simple extends FlxUIPopup
{
	public override function create():Void
	{
		_xml_id = "popup_simple";
		super.create();
		_ui.setMode("demo");
	}
	
	public override function eventResponse(id:String, target:Dynamic, data:Array<Dynamic>):Void 
	{
		if (data != null) {
			if(id == "click_button"){
				switch(Std.int(data[0])) {
					case 0: close();
				}
			}
		}
	}
	
}