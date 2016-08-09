package flixel.system.frontEnds;

import flixel.math.FlxPoint;
using flixel.util.FlxArrayUtil;
using flixel.util.FlxStringUtil;

#if js
import js.Browser;

class HTML5FrontEnd
{
	public var browser(default, null):FlxBrowser;
	public var platform(default, null):FlxPlatform;
	public var isMobile(default, null):Bool;
	public var browserWidth(get, never):Int;
	public var browserHeight(get, never):Int;
	public var browserPosition(get, null):FlxPoint;
	
	@:allow(flixel.FlxG)
	private function new()
	{
		browser = getBrowser();
		platform = getPlatform();
		isMobile = getIsMobile();
	}
	
	private function getBrowser():FlxBrowser
	{
		if (userAgentContains(" OPR/"))
		{
			return OPERA;
		}
		else if (userAgentContains("chrome", true))
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
	
	private function getPlatform():FlxPlatform
	{
		if (userAgentContains("Win"))
		{
			return WINDOWS;
		}
		else if (userAgentContains("Mac") && !userAgentContains("iPad"))
		{
			return MAC;
		}
		else if (userAgentContains("Linux") && !userAgentContains("Android"))
		{
			return LINUX;
		}
		else if (userAgentContains("IEMobile"))
		{
			return WINDOWS_PHONE;
		}
		else if (userAgentContains("Android"))
		{
			return ANDROID;
		}
		else if (userAgentContains("BlackBerry"))
		{
			return BLACKBERRY;
		}
		else if (userAgentContains("iPhone"))
		{
			return IOS(IPHONE);
		}
		else if (userAgentContains("iPad"))
		{
			return IOS(IPAD);
		}
		else if (userAgentContains("iPod"))
		{
			return IOS(IPOD);
		}
		else return FlxPlatform.UNKNOWN;
	}
	
	private function getIsMobile():Bool 
	{
		return Type.enumConstructor(platform) == "IOS" || [ANDROID, BLACKBERRY, WINDOWS_PHONE].contains(platform);
	}
	
	private function userAgentContains(substring:String, toLowerCase:Bool = false)
	{
		var userAgent = Browser.navigator.userAgent;
		if (toLowerCase)
			userAgent = userAgent.toLowerCase();
		return userAgent.contains(substring);
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
	MAC;
	ANDROID;
	BLACKBERRY;
	WINDOWS_PHONE;
	IOS(device:FlxIOSDevice);
	UNKNOWN;
}

enum FlxIOSDevice
{
	IPHONE;
	IPAD;
	IPOD;
}
#end