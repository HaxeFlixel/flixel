package flixel.system.frontEnds;

import flixel.math.FlxPoint;

#if js
import js.Browser;

class HTML5FrontEnd
{
	public var browser(get, never):FlxBrowser;
	public var browserWidth(get, never):Int;
	public var browserHeight(get, never):Int;
	public var browserPosition(get, null):FlxPoint;
	public var platform(get, never):FlxPlatform;
	public var isMobile(get, never):Bool;
	
	@:allow(flixel.FlxG)
	private function new() {}
	
	private function get_browser():FlxBrowser
	{
		if (Browser.navigator.userAgent.indexOf(" OPR/") > -1)
		{
			return OPERA;
		}
		else if (Browser.navigator.userAgent.toLowerCase().indexOf("chrome") > -1)
		{
			return CHROME;
		}
		else if (Browser.navigator.appName == "Netscape")
		{
			return FIREFOX;
		}
		else if (untyped false || !!document.documentMode)
		{
			return INTERNET_EXPLORER;
		}
		else if (untyped Object.prototype.toString.call(window.HTMLElement).indexOf("Constructor") > 0)
		{
			return SAFARI;
		}
		return FlxBrowser.UNKNOWN;
	}
	
	private function get_browserPosition():FlxPoint
	{
		if (browserPosition == null)
		{
			browserPosition = FlxPoint.get(0, 0);
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
	
	private inline function get_platform():FlxPlatform
	{
		
		if (Browser.navigator.userAgent.indexOf("Win") > -1)
		{
			return WINDOWS;
		}
		else if (Browser.navigator.userAgent.indexOf("Linux") > -1
		&& Browser.navigator.userAgent.indexOf("Android") == -1)
		{
			return LINUX;
		}
		else if (Browser.navigator.userAgent.indexOf("X11") > -1)
		{
			return UNIX;
		}
		else if (Browser.navigator.userAgent.indexOf("Android") > -1)
		{
			return ANDROID;
		}
		else if (Browser.navigator.userAgent.indexOf("BlackBerry") > -1)
		{
			return BLACKBERRY;
		}
		else if (Browser.navigator.userAgent.indexOf("iPhone") > -1
		|| Browser.navigator.userAgent.indexOf("iPad") > -1
		|| Browser.navigator.userAgent.indexOf("iPod") > -1)
		{
			return IOS;
		}
		else if (Browser.navigator.userAgent.indexOf("IEMobile") > -1)
		{
			return WINDOWS_PHONE;
		}
		else return FlxPlatform.UNKNOWN;
	}
	
	private inline function get_isMobile():Bool 
	{
		var platform = this.platform;
		return platform == ANDROID || platform == BLACKBERRY || platform == IOS || platform == WINDOWS_PHONE;
	}
}

enum FlxBrowser
{
	INTERNET_EXPLORER;
	CHROME;
	FIREFOX;
	SAFARI;
	OPERA;
	UNKNOWN;
}

enum FlxPlatform
{
	WINDOWS;
	LINUX;
	UNIX;
	MAC;
	ANDROID;
	BLACKBERRY;
	WINDOWS_PHONE;
	IOS;
	UNKNOWN;
}
#end