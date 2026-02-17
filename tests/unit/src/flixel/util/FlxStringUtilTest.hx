package flixel.util;

import flixel.system.debug.FlxDebugger.FlxDebuggerLayout;
import massive.munit.Assert;
import openfl.display.BitmapData;

class FlxStringUtilTest
{
	@Before
	function before()
	{
		FlxStringUtil.isBrowserManipulatingImages = false;
	}
	
	@Test
	function testBitmapToCSVSimple()
	{
		var bitmapData = new BitmapData(3, 3);
		bitmapData.setPixel32(0, 0, FlxColor.BLACK);
		bitmapData.setPixel32(1, 1, FlxColor.BLACK);
		bitmapData.setPixel32(2, 2, FlxColor.BLACK);

		var expected = "1, 0, 0\n" + "0, 1, 0\n" + "0, 0, 1";
		var actual = FlxStringUtil.bitmapToCSV(bitmapData);

		Assert.areEqual(expected, actual);
	}

	@Test
	function testBitmapToCSVInverted()
	{
		var bitmapData = new BitmapData(3, 3, true, FlxColor.BLACK);
		bitmapData.setPixel32(0, 0, FlxColor.WHITE);
		bitmapData.setPixel32(1, 1, FlxColor.WHITE);
		bitmapData.setPixel32(2, 2, FlxColor.WHITE);

		var expected = "1, 0, 0\n" + "0, 1, 0\n" + "0, 0, 1";
		var actual = FlxStringUtil.bitmapToCSV(bitmapData, true);

		Assert.areEqual(expected, actual);
	}

	@Test
	function testBitmapToCSVWithScale()
	{
		var bitmapData = new BitmapData(2, 2);
		bitmapData.setPixel32(0, 0, FlxColor.BLACK);
		bitmapData.setPixel32(1, 1, FlxColor.BLACK);

		var expected = "1, 1, 0, 0\n" + "1, 1, 0, 0\n" + "0, 0, 1, 1\n" + "0, 0, 1, 1";
		var actual = FlxStringUtil.bitmapToCSV(bitmapData, false, 2);

		Assert.areEqual(expected, actual);
	}

	@Test
	function testBitmapToCSVWithColorMap()
	{
		var bitmapData = new BitmapData(3, 3);
		bitmapData.setPixel32(0, 0, FlxColor.BLACK);
		bitmapData.setPixel32(1, 1, FlxColor.RED);
		bitmapData.setPixel32(2, 1, 0x80ff0000); // ignore alpha
		bitmapData.setPixel32(2, 2, FlxColor.YELLOW);

		final expected = "1, 0, 0\n" + "0, 2, 2\n" + "0, 0, 3";

		final colorMap = [FlxColor.WHITE, FlxColor.BLACK, FlxColor.RED, FlxColor.YELLOW];
		final actual = FlxStringUtil.bitmapToCSV(bitmapData, 1, colorMap);

		Assert.areEqual(expected, actual);
	}

	@Test
	function testBitmap32ToCSV()
	{
		final bitmapData = new BitmapData(3, 3);
		bitmapData.setPixel32(0, 0, FlxColor.BLACK);
		bitmapData.setPixel32(1, 1, FlxColor.RED);
		bitmapData.setPixel32(2, 1, 0x80ff0000); // honor alpha
		bitmapData.setPixel32(2, 2, FlxColor.YELLOW);
		
		final expected = '1, 0, 0\n0, 2, 4\n0, 0, 3';
		final colorMap = [FlxColor.WHITE, FlxColor.BLACK, FlxColor.RED, FlxColor.YELLOW, 0x80ff0000];
		final actual = FlxStringUtil.bitmap32ToCSV(bitmapData, 1, colorMap);

		Assert.areEqual(expected, actual);
	}

	@Test
	@:haxe.warning("-WDeprecated")
	function testBitmapToCSVOverloads()
	{
		final bitmapData = new BitmapData(3, 3);
		final colorMap = [FlxColor.WHITE, FlxColor.BLACK, FlxColor.RED, FlxColor.YELLOW];
		FlxStringUtil.bitmapToCSV(bitmapData, false, 1, colorMap); // deprecated
		FlxStringUtil.bitmapToCSV(bitmapData, false, 1);
		FlxStringUtil.bitmapToCSV(bitmapData, false);
		FlxStringUtil.bitmapToCSV(bitmapData, 1, colorMap);
		FlxStringUtil.bitmap32ToCSV(bitmapData, 1, colorMap);
		#if !flash
		FlxStringUtil.bitmapToCSV(bitmapData, 1);
		FlxStringUtil.bitmapToCSV(bitmapData, colorMap);
		FlxStringUtil.bitmap32ToCSV(bitmapData, colorMap);
		#end
	}
	
	@Test // https://github.com/HaxeFlixel/flixel/issues/3541
	function testBitmapToCSVAntiFarbling()
	{
		final bitManips = [0x00000000, 0x01000000, 0x00010000, 0x00000100, 0x00000001];
		final columns = bitManips.length;
		final bitmapData = new BitmapData(columns, 2);
		for (i in 0...columns * bitmapData.height)
		{
			final column = i % columns;
			final row = Std.int(i / columns);
			final color = (i < columns ? 0xFF000000 : 0xFFffffff) ^ bitManips[column];
			bitmapData.setPixel32(column, row, color);
		}
		
		// without farbling
		var errorCount = 0;
		function onError(data, ?pos) errorCount++;
		
		FlxG.log.styles.error.onLog.add(onError);
		FlxStringUtil.isBrowserManipulatingImages = false;
		final expected = '0, 0, 0, 0, 0\n1, 0, 0, 0, 0';
		final actual = FlxStringUtil.bitmap32ToCSV(bitmapData, 1, [FlxColor.BLACK, FlxColor.WHITE]);
		Assert.areEqual(expected, actual);
		Assert.areEqual(8, errorCount);
		FlxG.log.styles.error.onLog.remove(onError);
		
		// with farbling
		var noticeCount = 0;
		function onNotice(_, ?_) noticeCount++;
		
		FlxG.log.styles.notice.onLog.add(onNotice);
		FlxStringUtil.isBrowserManipulatingImages = true;
		
		final expected = '0, 0, 0, 0, 0\n1, 1, 1, 1, 1';
		final actual = FlxStringUtil.bitmap32ToCSV(bitmapData, 1, [FlxColor.BLACK, FlxColor.WHITE]);
		Assert.areEqual(expected, actual);
		Assert.areEqual(8, noticeCount);
		FlxG.log.styles.notice.onLog.remove(onNotice);
	}

	@Test
	function testArrayToCSV()
	{
		Assert.areEqual("0, 3, 4\n5, 0, 7", FlxStringUtil.arrayToCSV([0, 3, 4, 5, 0, 7], 3));
	}
	
	@Test
	function testFormatMoney()
	{
		Assert.areEqual("110.20", FlxStringUtil.formatMoney(110.2));
		Assert.areEqual("110", FlxStringUtil.formatMoney(110.2, false));
		Assert.areEqual("100,000,000.00", FlxStringUtil.formatMoney(100000000));
		Assert.areEqual("10,000,000,000.00", FlxStringUtil.formatMoney(10000000000)); // #2120
		Assert.areEqual("100.000.000,00", FlxStringUtil.formatMoney(100000000, true, false));
		Assert.areEqual("0.60", FlxStringUtil.formatMoney(0.6)); // #1754
		Assert.areEqual("0", FlxStringUtil.formatMoney(0.6, false));
		Assert.areEqual("0.00", FlxStringUtil.formatMoney(0));
		Assert.areEqual("4.03", FlxStringUtil.formatMoney(4.0312));

		Assert.areEqual("-100,000,000.00", FlxStringUtil.formatMoney(-100000000));
		Assert.areEqual("-110.20", FlxStringUtil.formatMoney(-110.2));
		Assert.areEqual("-0.60", FlxStringUtil.formatMoney(-0.6));
	}

	@Test
	function testIsNullOrEmpty()
	{
		Assert.isTrue(FlxStringUtil.isNullOrEmpty(null));
		Assert.isTrue(FlxStringUtil.isNullOrEmpty(""));
		Assert.isFalse(FlxStringUtil.isNullOrEmpty("."));
		Assert.isFalse(FlxStringUtil.isNullOrEmpty("Hello World"));
	}

	/**
	 * Returns an array of valid URLs for testing.
	 *
	 * @param	host	The host to insert into the generated URLs.
	 */
	function generateTestURLs(host:String):Array<String>
	{
		var urls = new Array<String>();

		var protocols = ["http://", "fake.but-valid+scheme://", ""];
		var authorities = ['$host', 'user@$host', '$host:1234'];
		var paths = ["", "/", "/index.html", "/path/to/file.extension?query=42"];

		for (protocol in protocols)
			for (authority in authorities)
				for (path in paths)
					urls.push(mixedCase('$protocol$authority$path'));

		return urls;
	}

	/**
	 * Returns a string with a mixture of upper and lower case characters.
	 */
	function mixedCase(string:String):String
	{
		var result = "", upper = (string.length % 2 == 0);
		for (i in 0...string.length)
		{
			var char = string.charAt(i);
			result += (upper = !upper) ? char.toUpperCase() : char.toLowerCase();
		}
		return result;
	}

	/**
	 * Returns an array of local file paths for testing.
	 * Includes Unix-style and Windows-style paths as well as a file:// URL.
	 */
	function generateLocalPaths():Array<String>
	{
		return [
			"/root/folder/file.extension",
			"./folder/file.extension",
			"~/.extension",
			"D:\\folder\\file.extension",
			"D:\\folder\\file.extension:alternate_stream_name",
			"D:file.extension",
			"\\\\server\\folder\\file.extension",
			"\\\\?\\D:\\folder\\file.extension",
			"file:///D:/folder/file.extension"
		];
	}

	@Test
	function testGetHostValidURLs()
	{
		var hosts = ["123.45.67.89", "[1234:5678:9abc:def0::1]", "asdf.xn--eckwd4c7c.test"];
		for (host in hosts)
			for (url in generateTestURLs(host))
				Assert.areEqual(host, FlxStringUtil.getHost(url));

		Assert.areEqual("abc.test", FlxStringUtil.getHost("http://%41%42%43.test"));
	}

	@Test
	function testGetHostInvalidURLs()
	{
		for (path in generateLocalPaths())
			Assert.areEqual("", FlxStringUtil.getHost(path));
	}

	@Test
	function testGetDomainNonLocal()
	{
		var domain = "xn--eckwd4c7c.test";
		for (url in generateTestURLs('extra.data.$domain'))
			Assert.areEqual(domain, FlxStringUtil.getDomain(url));
	}

	@Test
	function testGetDomainLocal()
	{
		var hosts = ["localhost", "123.45.67.89", "[1234:5678:9abc:def0::1]"];
		for (host in hosts)
			for (url in generateTestURLs(host))
				Assert.areEqual("", FlxStringUtil.getDomain(url));

		for (path in generateLocalPaths())
			Assert.areEqual("", FlxStringUtil.getDomain(path));
	}

	@Test
	function testGetClassName()
	{
		function test(value:Dynamic, simple:Bool, expected:String)
			Assert.areEqual(FlxStringUtil.getClassName(value, simple), expected);

		var longName = "flixel.FlxSprite";
		var shortName = "FlxSprite";

		test(FlxSprite, false, longName);
		test(FlxSprite, true, shortName);
		test(new FlxSprite(), false, longName);
		test(new FlxSprite(), true, shortName);
	}

	@Test
	function testGetEnumName()
	{
		function test(value, simple:Bool, expected:String)
			Assert.areEqual(FlxStringUtil.getEnumName(value, simple), expected);

		var longName = "flixel.system.debug.FlxDebuggerLayout";
		var shortName = "FlxDebuggerLayout";

		test(FlxDebuggerLayout, false, longName);
		test(FlxDebuggerLayout, true, shortName);
		test(FlxDebuggerLayout.BIG, false, longName);
		test(FlxDebuggerLayout.BIG, true, shortName);
	}
}
