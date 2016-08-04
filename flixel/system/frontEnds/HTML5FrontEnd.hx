package flixel.system.frontEnds;

import flixel.math.FlxPoint;
import flixel.system.frontEnds.HTML5FrontEnd.IOSPlatform;
import flixel.util.FlxStringUtil;

#if js
import js.Browser;

class HTML5FrontEnd
{
	public var browser(default, null):FlxBrowser;
	public var ios(default, null):IOSPlatform;
	public var platform(default, null):FlxPlatform;
	public var isMobile(default, null):Bool;
	public var browserWidth(get, null):Int;
	public var browserHeight(get, null):Int;
	public var browserPosition(get, null):FlxPoint;
	
	@:allow(flixel.FlxG)
	private function new()
	{
		browser = getBrowser();
		ios = getiOS();
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
	
	private function getiOS():IOSPlatform
	{
		if (userAgentContains("iPhone"))
		{
			return IPHONE;
		}
		else if (userAgentContains("iPad"))
		{
			return IPAD;
		}
		else if (userAgentContains("iPod"))
		{
			return IPOD;
		}
		else return IOSPlatform.UNKNOWN;
	}
	
	private function getPlatform():FlxPlatform
	{
		
		if (userAgentContains("Win"))
		{
			return WINDOWS;
		}
		else if (userAgentContains("Mac"))
		{
			return MAC;
		}
		else if (userAgentContains("Linux")
		&& !userAgentContains("Android"))
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
		else if (ios != IOSPlatform.UNKNOWN)
		{
			return IOS;
		}
		else return FlxPlatform.UNKNOWN;
	}
	
	private inline function getIsMobile():Bool 
	{
		var mobilePlatforms:Array<FlxPlatform> = [ANDROID, BLACKBERRY, WINDOWS_PHONE, IOS];
		return mobilePlatforms.indexOf(platform) != -1;
	}
	
	private inline function userAgentContains(substring:String, toLowerCase:Bool = false)
	{
		var userAgent = Browser.navigator.userAgent;
		if (toLowerCase)
			userAgent = userAgent.toLowerCase();
		return FlxStringUtil.contains(userAgent, substring);
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
	IOS;
	UNKNOWN;
}
enum IOSPlatform
{
	IPHONE;
	IPAD;
	IPOD;
	UNKNOWN;
}
#end