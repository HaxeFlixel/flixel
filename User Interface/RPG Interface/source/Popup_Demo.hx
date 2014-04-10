import flixel.addons.ui.FlxUIPopup;

class Popup_Demo extends FlxUIPopup
{
	public override function create():Void
	{		
		_xml_id = "popup_demo";
		super.create();
		_ui.setMode("demo_0");
	}
	
	public override function getEvent(id:String, target:Dynamic, data:Array<Dynamic>, ?params:Array<Dynamic>):Void 
	{
		if (params != null && params.length > 0) {
			if (id == "click_button") {
				var i:Int = cast params[0];
				if (_ui.currMode == "demo_0"){
					switch(i) {
						case 0: openSubState(new Popup_Simple());
						case 1: _ui.setMode("demo_1");
						case 2: close();
					}
				} else if (_ui.currMode == "demo_1") {
					switch(i) {
						case 0: _ui.setMode("demo_0");
						case 1: close();
					}
				}
			}
		}
	}
}