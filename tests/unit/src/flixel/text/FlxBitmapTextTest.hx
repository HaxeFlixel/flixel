package flixel.text;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import massive.munit.Assert;
import openfl.display.BitmapData;

class FlxBitmapTextTest extends FlxTest
{
	var text:FlxBitmapText;

	@Before
	function before():Void
	{
		text = new FlxBitmapText();
		destroyable = text;
	}
	
	@Test // #1526 and #2750
	function testCreateSpriteSkipPosition()
	{
		final text1 = new FlxBitmapText("test");
		final text2 = new FlxBitmapText(FlxBitmapFont.getDefaultFont());

		Assert.areEqual(0, text1.x);
		Assert.areEqual(0, text1.y);
		Assert.areEqual(0, text2.x);
		Assert.areEqual(0, text2.y);

		Assert.isNotNull(text1.text);
		Assert.areEqual(text1.font, text2.font);
	}
	
	@Test
	function testWrapMono()
	{
		final image = new BitmapData(112, 60);
		final monospaceLetters:String = " !\"#$%&'()*+,-.\\0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[/]^_`abcdefghijklmnopqrstuvwxyz{|}~";
		final charSize = FlxPoint.get(7, 10);
		final font = FlxBitmapFont.fromMonospace(image, monospaceLetters, charSize);
		
		final field = new FlxBitmapText(0, 0, "", font);
		field.autoSize = false;
		field.fieldWidth = 100;
		field.letterSpacing = -1;
		field.multiLine = true;
		
		/*
		Note: These tests were made quickly due to my current schedule, later on we may want
		to simplify these, and also add tests for: kerning and unicode stuff
		*/
		
		final msg = "The quick brown fox jumps over the lazy dog, ";
		final msg1 = msg + "supercal-aphragalist-icexpiala-docious"; // long hyphenate4d word
		final msg2 = msg + "supercal-aphragalist\nicexpiala-docious"; // hard wrap and hyphens
		final msg3 = msg + "supercalaphragalisticexpialadocious"; // one long word
		
		assertRenderedText(field, msg1, NONE, "The quick brown ");
		assertRenderedText(field, msg2, NONE, "The quick brown \nicexpiala-dociou");
		assertRenderedText(field, msg3, NONE, "The quick brown ");
		
		assertRenderedText(field, msg1, CHAR, "The quick brown \nfox jumps over t\nhe lazy dog, sup\nercal-aphragalis\nt-icexpiala-doci\nous");
		assertRenderedText(field, msg2, CHAR, "The quick brown \nfox jumps over t\nhe lazy dog, sup\nercal-aphragalis\nt\nicexpiala-dociou\ns");
		assertRenderedText(field, msg3, CHAR, "The quick brown \nfox jumps over t\nhe lazy dog, sup\nercalaphragalist\nicexpialadocious");
		
		assertRenderedText(field, msg1, WORD(NEVER), "The quick brown \nfox jumps over \nthe lazy dog, \nsupercal-\naphragalist-\nicexpiala-\ndocious");
		assertRenderedText(field, msg2, WORD(NEVER), "The quick brown \nfox jumps over \nthe lazy dog, \nsupercal-\naphragalist\nicexpiala-\ndocious");
		assertRenderedText(field, msg3, WORD(NEVER), "The quick brown \nfox jumps over \nthe lazy dog, \nsupercalaphragalisticexpialadocious");
		
		assertRenderedText(field, msg1, WORD(LINE_WIDTH), "The quick brown \nfox jumps over \nthe lazy dog, \nsupercal-\naphragalist-\nicexpiala-\ndocious");
		assertRenderedText(field, msg2, WORD(LINE_WIDTH), "The quick brown \nfox jumps over \nthe lazy dog, \nsupercal-\naphragalist\nicexpiala-\ndocious");
		assertRenderedText(field, msg3, WORD(LINE_WIDTH), "The quick brown \nfox jumps over \nthe lazy dog, su\npercalaphragalis\nticexpialadociou\ns");
		
		assertRenderedText(field, msg1, WORD(LENGTH(10)), "The quick brown \nfox jumps over \nthe lazy dog, \nsupercal-aphraga\nlist-icexpiala-\ndocious");
		assertRenderedText(field, msg2, WORD(LENGTH(10)), "The quick brown \nfox jumps over \nthe lazy dog, \nsupercal-aphraga\nlist\nicexpiala-\ndocious");
		assertRenderedText(field, msg3, WORD(LENGTH(10)), "The quick brown \nfox jumps over \nthe lazy dog, su\npercalaphragalis\nticexpialadociou\ns");
	}
	
	function assertRenderedText(field:FlxBitmapText, text:UnicodeString, wrap:FlxBitmapText.Wrap, expected:UnicodeString, ?info:haxe.PosInfos)
	{
		field.wrap = wrap;
		final actual = field.getRenderedText(text);
		Assert.areEqual(expected, actual, info);
	}
}
