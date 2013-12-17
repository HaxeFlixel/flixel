package flixel.system.frontEnds;
import flixel.util.FlxPoint;
import js.Browser;

#if js
class HTML5FrontEnd
{
	public var browser(get, null):String;
	public var browserPosition(get, null):FlxPoint;
	public var browserWidth(get, null):Int;
	public var browserHeight(get, null):Int;
	
	public function new()
	{
		
	}
	
	private function get_browser():String
	{
		if (Browser.navigator.userAgent.indexOf(" OPR/") > -1) return "Opera";
		else if (Browser.navigator.userAgent.toLowerCase().indexOf("chrome") > -1) return "Chrome";
		else if (Browser.navigator.appName == "Netscape") return "Firefox";
		else if (untyped false || !!document.documentMode) return "IE";
		else if (untyped Object.prototype.toString.call(window.HTMLElement).indexOf("Constructor") > 0) return "Safari";
		return "Unknown";
	}
	
	private function get_browserPosition():FlxPoint
	{
		if (browserPosition == null) browserPosition = new FlxPoint(0, 0);
		browserPosition.set(Browser.window.screenX, Browser.window.screenY);
		return browserPosition;
	}
	
	private function get_browserWidth():Int
	{
		return Browser.window.innerWidth;
	}
	
	private function get_browserHeight():Int
	{
		return Browser.window.innerHeight;
	}
}
#end
