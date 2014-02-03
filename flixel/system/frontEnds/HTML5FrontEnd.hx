package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.util.FlxPoint;

#if js
import js.Browser;

class HTML5FrontEnd
{
	/**
	 * Constants for the different browsers returned by <code>browser</code>
	 */
	public static inline var INTERNET_EXPLORER:String = "Internet Explorer";
	public static inline var CHROME           :String = "Chrome";
	public static inline var FIREFOX          :String = "Firefox";
	public static inline var SAFARI           :String = "Safari";
	public static inline var OPERA            :String = "Opera";
	
	public var browser        (get, never):String;
	public var browserWidth   (get, never):Int;
	public var browserHeight  (get, never):Int;
	public var browserPosition(get, null):FlxPoint;
	
	@:allow(flixel.FlxG) private function new() {}
	
	private function get_browser():String
	{
		if (Browser.navigator.userAgent.indexOf(" OPR/") > -1) {
			return OPERA;
		}
		else if (Browser.navigator.userAgent.toLowerCase().indexOf("chrome") > -1) {
			return CHROME;
		}
		else if (Browser.navigator.appName == "Netscape") {
			return FIREFOX;
		}
		else if (untyped false || !!document.documentMode) {
			return INTERNET_EXPLORER;
		}
		else if (untyped Object.prototype.toString.call(window.HTMLElement).indexOf("Constructor") > 0) {
			return SAFARI;
		}
		return "Unknown";
	}
	
	private function get_browserPosition():FlxPoint
	{
		if (browserPosition == null) {
			browserPosition = new FlxPoint(0, 0);
		}
		browserPosition.set(Browser.window.screenX, Browser.window.screenY);
		return browserPosition;
	}
	
	private inline function get_browserWidth():Int
	{
		return Browser.window.innerWidth;
	}
	
	private inline function get_browserHeight():Int
	{
		return Browser.window.innerHeight;
	}
}
#end