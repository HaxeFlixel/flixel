package flixel.system.frontEnds;

#if js
import js.Browser;
import flixel.math.FlxPoint;

using flixel.util.FlxStringUtil;

/**
 * Tools and helpers relating to the js/html5 target.
 *
 * Accessed via `FlxG.html5`.
 */
class HTML5FrontEnd
{
	public var browser(default, null):FlxBrowser;

	/** @since 4.2.0 */
	public var platform(default, null):FlxPlatform;

	/** @since 4.2.0 */
	public var onMobile(default, null):Bool;

	public var browserWidth(get, never):Int;
	public var browserHeight(get, never):Int;
	public var browserPosition(get, null):FlxPoint;

	@:allow(flixel.FlxG)
	function new()
	{
		browser = getBrowser();
		platform = getPlatform();
		onMobile = getOnMobile();
	}

	function getBrowser():FlxBrowser
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

	function getPlatform():FlxPlatform
	{
		if (userAgentContains("Win"))
		{
			return WINDOWS;
		}
		else if (userAgentContains("IEMobile"))
		{
			return WINDOWS_PHONE;
		}
		else if (userAgentContains("Android"))
		{
			return ANDROID;
		}
		else if (userAgentContains("Linux"))
		{
			return LINUX;
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
		else if (userAgentContains("Mac"))
		{
			return MAC;
		}
		else
			return FlxPlatform.UNKNOWN;
	}

	function getOnMobile():Bool
	{
		return switch (platform)
		{
			case ANDROID, BLACKBERRY, WINDOWS_PHONE, IOS(_):
				true;
			default:
				false;
		}
	}

	function userAgentContains(substring:String, toLowerCase:Bool = false)
	{
		var userAgent = Browser.navigator.userAgent;
		if (toLowerCase)
			userAgent = userAgent.toLowerCase();
		return userAgent.contains(substring);
	}

	function get_browserPosition():FlxPoint
	{
		if (browserPosition == null)
		{
			browserPosition = FlxPoint.get(0, 0);
		}
		browserPosition.set(Browser.window.screenX, Browser.window.screenY);
		return browserPosition;
	}

	inline function get_browserWidth():Int
	{
		return Browser.window.innerWidth;
	}

	inline function get_browserHeight():Int
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
