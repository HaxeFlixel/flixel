package flixel.graphics.frames.bmfont;

import haxe.io.Bytes;
import massive.munit.Assert;

class BMFontTest extends FlxTest
{
	@Test
	function testTextFormat()
	{
		var text = 'info face="Arial Black" size=32 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=1,2,3,4 spacing=2,1 outline=0
common lineHeight=32 base=25 scaleW=256 scaleH=256 pages=1 packed=0 alphaChnl=1 redChnl=0 greenChnl=0 blueChnl=0
page id=0 file="arial_black_0.png"
chars count=3
char id=64   x=0     y=0     width=25    height=24    xoffset=-5    yoffset=7     xadvance=17    page=0  chnl=15
char id=65   x=27    y=0     width=26    height=21    xoffset=-5    yoffset=7     xadvance=18    page=0  chnl=15
char id=84   x=55    y=0     width=23    height=21    xoffset=-4    yoffset=7     xadvance=16    page=0  chnl=15
kernings count=2
kerning first=84  second=65  amount=-2  
kerning first=65  second=84  amount=-2  
';

		var font = BMFont.parse(cast text);
		assertFont(font);
	}

	@Test
	function testXMLFormat()
	{
		var xml = '<?xml version="1.0"?>
		<font>
		  <info face="Arial Black" size="32" bold="0" italic="0" charset="" unicode="1" stretchH="100" smooth="1" aa="1" padding="1,2,3,4" spacing="2,1" outline="0"/>
		  <common lineHeight="32" base="25" scaleW="256" scaleH="256" pages="1" packed="0" alphaChnl="1" redChnl="0" greenChnl="0" blueChnl="0"/>
		  <pages>
			<page id="0" file="arial_black_0.png" />
		  </pages>
		  <chars count="3">
			<char id="64" x="0" y="0" width="25" height="24" xoffset="-5" yoffset="7" xadvance="17" page="0" chnl="15" />
			<char id="65" x="27" y="0" width="26" height="21" xoffset="-5" yoffset="7" xadvance="18" page="0" chnl="15" />
			<char id="84" x="55" y="0" width="23" height="21" xoffset="-4" yoffset="7" xadvance="16" page="0" chnl="15" />
		  </chars>
		  <kernings count="2">
			<kerning first="84" second="65" amount="-2" />
			<kerning first="65" second="84" amount="-2" />
		  </kernings>
		</font>';

		var font = BMFont.parse(cast xml);
		assertFont(font);
	}

	@Test
	function testBinaryFormat()
	{
		var binary = Bytes.ofHex("424D4603011A0000002000C00064000101020304020" +
		"100417269616C20426C61636B00020F0000002000190000010001010000010000000" +
		"312000000617269616C5F626C61636B5F302E706E6700043C0000004000000000000" +
		"00019001800FBFF07001100000F410000001B0000001A001500FBFF07001200000F5" +
		"40000003700000017001500FCFF07001000000F05140000005400000041000000FEF" +
		"F4100000054000000FEFF");

		var font = BMFont.parse(cast binary);
		assertFont(font);
	}

	// This assumes the incoming font has a specific configuration we are checking for
	private function assertFont(font:BMFont) {
		trace(font);

		// INFO
		Assert.areEqual("Arial Black", font.info.face);
		Assert.areEqual(32, font.info.size);
		Assert.areEqual(false, font.info.bold);
		Assert.areEqual(false, font.info.italic);
		Assert.isEmpty(font.info.charset);
		Assert.areEqual(true, font.info.unicode);
		Assert.areEqual(100, font.info.stretchH);
		Assert.areEqual(true, font.info.smooth);
		Assert.areEqual(1, font.info.aa);
		Assert.areEqual(1, font.info.padding.up);
		Assert.areEqual(2, font.info.padding.right);
		Assert.areEqual(3, font.info.padding.down);
		Assert.areEqual(4, font.info.padding.left);
		Assert.areEqual(2, font.info.spacing.x);
		Assert.areEqual(1, font.info.spacing.y);
		Assert.areEqual(0, font.info.outline);

		// COMMON
		Assert.areEqual(32, font.common.lineHeight);
		Assert.areEqual(25, font.common.base);
		Assert.areEqual(256, font.common.scaleW);
		Assert.areEqual(256, font.common.scaleH);
		Assert.areEqual(1, font.common.pages);
		Assert.areEqual(false, font.common.packed);
		Assert.areEqual(1, font.common.alphaChnl);
		Assert.areEqual(0, font.common.redChnl);
		Assert.areEqual(0, font.common.greenChnl);
		Assert.areEqual(0, font.common.blueChnl);

		// PAGES
		Assert.areEqual(1, font.pages.length);
		Assert.areEqual(0, font.pages[0].id);
		Assert.areEqual("arial_black_0.png", font.pages[0].file);

		// Chars
		Assert.areEqual(3, font.chars.length);
		var expectedChars:Array<BMFontChar> = [
			{
				id: 64,
				x: 0,
				y: 0,
				width: 25,
				height: 24,
				xoffset: -5,
				yoffset: 7,
				xadvance: 17,
				page: 0,
				chnl: 15,
				letter: "@"
			},
			{
				id: 65,
				x: 27,
				y: 0,
				width: 26,
				height: 21,
				xoffset: -5,
				yoffset: 7,
				xadvance: 18,
				page: 0,
				chnl: 15,
				letter: "A"
			},
			{
				id: 84,
				x: 55,
				y: 0,
				width: 23,
				height: 21,
				xoffset: -4,
				yoffset: 7,
				xadvance: 16,
				page: 0,
				chnl: 15,
				letter: "T"
			},
		];

		for (i in 0...expectedChars.length) {
			assertCharMatches(expectedChars[i], font.chars[i]);
		}

		// Kerning
		Assert.areEqual(font.chars.length, 3);
		var expectedKerns:Array<BMFontKerning> = [
			{
				first: 84,
				second: 65,
				amount: -2
			},
			{
				first: 65,
				second: 84,
				amount: -2
			},
		];

		for (i in 0...expectedKerns.length) {
			assertKerningMatches(expectedKerns[i], font.kerning[i]);
		}
	}

	private function assertCharMatches(expected:BMFontChar, actual:BMFontChar) {
		Assert.areEqual(expected.id, actual.id);
		Assert.areEqual(expected.x, actual.x);
		Assert.areEqual(expected.y, actual.y);
		Assert.areEqual(expected.width, actual.width);
		Assert.areEqual(expected.height, actual.height);
		Assert.areEqual(expected.xoffset, actual.xoffset);
		Assert.areEqual(expected.yoffset, actual.yoffset);
		Assert.areEqual(expected.xadvance, actual.xadvance);
		Assert.areEqual(expected.page, actual.page);
		Assert.areEqual(expected.chnl, actual.chnl);
		// if (expected.letter != null) {
		// 	Assert.areEqual(expected.letter, actual.letter);
		// }
	}

	private function assertKerningMatches(expected:BMFontKerning, actual:BMFontKerning) {
		Assert.areEqual(expected.first, actual.first);
		Assert.areEqual(expected.second, actual.second);
		Assert.areEqual(expected.amount, actual.amount);
	}
}