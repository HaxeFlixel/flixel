package flixel.graphics.frames.bmfont;

import massive.munit.Assert;
// import flixel.graphics.frames.bmfont.;

class BMFontTest extends FlxTest
{
	@Test
	function testXMLFormat()
	{
		var xml = '<?xml version="1.0"?>
		<font>
		  <info face="Test Font" size="32" bold="0" italic="0" charset="" unicode="1" stretchH="100" smooth="1" aa="1" padding="1,2,3,4" spacing="1,2" outline="0"/>
		  <common lineHeight="32" base="26" scaleW="256" scaleH="256" pages="1" packed="0" alphaChnl="1" redChnl="0" greenChnl="0" blueChnl="0"/>
		  <pages>
			<page id="0" file="tester_xml_0.png" />
		  </pages>
		  <chars count="3">
			<char id="64" x="0" y="0" width="26" height="26" xoffset="1" yoffset="6" xadvance="27" page="0" chnl="15" />
			<char id="65" x="40" y="26" width="19" height="20" xoffset="-1" yoffset="6" xadvance="18" page="0" chnl="15" />
			<char id="66" x="35" y="48" width="16" height="20" xoffset="1" yoffset="6" xadvance="18" page="0" chnl="15" />
		  </chars>
		  <kernings count="3">
			<kerning first="65" second="32" amount="-1" />
			<kerning first="65" second="84" amount="-2" />
			<kerning first="66" second="86" amount="-3" />
		  </kernings>
		</font>
		';

		var font = BMFont.parse(cast xml);

		// INFO
		Assert.areEqual(font.info.face, "Test Font");
		Assert.areEqual(font.info.size, 32);
		Assert.areEqual(font.info.bold, false);
		Assert.areEqual(font.info.italic, false);
		Assert.areEqual(font.info.charset, "");
		Assert.areEqual(font.info.unicode, true);
		Assert.areEqual(font.info.stretchH, 100);
		Assert.areEqual(font.info.smooth, true);
		Assert.areEqual(font.info.aa, 1);
		Assert.areEqual(font.info.padding.up, 1);
		Assert.areEqual(font.info.padding.right, 2);
		Assert.areEqual(font.info.padding.down, 3);
		Assert.areEqual(font.info.padding.left, 4);
		Assert.areEqual(font.info.spacing.x, 1);
		Assert.areEqual(font.info.spacing.y, 2);
		Assert.areEqual(font.info.outline, 0);

		// COMMON
		Assert.areEqual(font.common.lineHeight, 32);
		Assert.areEqual(font.common.base, 26);
		Assert.areEqual(font.common.scaleW, 256);
		Assert.areEqual(font.common.scaleH, 256);
		Assert.areEqual(font.common.pages, 1);
		Assert.areEqual(font.common.packed, false);
		Assert.areEqual(font.common.alphaChnl, 1);
		Assert.areEqual(font.common.redChnl, 0);
		Assert.areEqual(font.common.greenChnl, 0);
		Assert.areEqual(font.common.blueChnl, 0);

		// PAGES
		Assert.areEqual(font.pages.length, 1);
		Assert.areEqual(font.pages[0].id, 0);
		Assert.areEqual(font.pages[0].file, "tester_xml_0.png");

		// Chars
		Assert.areEqual(font.chars.length, 3);
		var expectedChars:Array<BMFontChar> = [
			{
				id: 64,
				x: 0,
				y: 0,
				width: 26,
				height: 26,
				xoffset: 1,
				yoffset: 6,
				xadvance: 27,
				page: 0,
				chnl: 15,
				letter: "@"
			},
			{
				id: 65,
				x: 40,
				y: 26,
				width: 19,
				height: 20,
				xoffset: -1,
				yoffset: 6,
				xadvance: 18,
				page: 0,
				chnl: 15,
				letter: "A"
			},
			{
				id: 66,
				x: 35,
				y: 48,
				width: 16,
				height: 20,
				xoffset: 1,
				yoffset: 6,
				xadvance: 18,
				page: 0,
				chnl: 15,
				letter: "B"
			},
		];

		for (i in 0...expectedChars.length) {
			assertCharMatches(expectedChars[i], font.chars[i]);
		}

		// Kerning
		Assert.areEqual(font.chars.length, 3);
		var expectedKerns:Array<BMFontKerning> = [
			{
				first: 65,
				second: 32,
				amount: -1
			},
			{
				first: 65,
				second: 84,
				amount: -2
			},
			{
				first: 66,
				second: 86,
				amount: -3
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