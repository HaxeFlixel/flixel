package flixel.text;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import massive.munit.Assert;
import openfl.display.BitmapData;

@:access(flixel.text.FlxBitmapText)
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
	
	@Test// #1526 and #2750
	#if cpp @Ignore("Failing on cpp") #end
	function testAutoBounds()
	{
		final text = new FlxBitmapText("test");
		text.autoBounds = false;
		text.offset.x = 100;
		text.text = "text.text.text";
		@:privateAccess
		text.checkPendingChanges(true);
		Assert.areEqual(100, text.offset.x);
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
		
		assertRenderedText(field, msg1, WORD(NEVER), "The quick brown\nfox jumps over\nthe lazy dog,\nsupercal-\naphragalist-\nicexpiala-\ndocious");
		assertRenderedText(field, msg2, WORD(NEVER), "The quick brown\nfox jumps over\nthe lazy dog,\nsupercal-\naphragalist\nicexpiala-\ndocious");
		assertRenderedText(field, msg3, WORD(NEVER), "The quick brown\nfox jumps over\nthe lazy dog,\nsupercalaphragalisticexpialadocious");
		
		assertRenderedText(field, msg1, WORD(LINE_WIDTH), "The quick brown\nfox jumps over\nthe lazy dog,\nsupercal-\naphragalist-\nicexpiala-\ndocious");
		assertRenderedText(field, msg2, WORD(LINE_WIDTH), "The quick brown\nfox jumps over\nthe lazy dog,\nsupercal-\naphragalist\nicexpiala-\ndocious");
		assertRenderedText(field, msg3, WORD(LINE_WIDTH), "The quick brown\nfox jumps over\nthe lazy dog, su\npercalaphragalis\nticexpialadociou\ns");
		
		assertRenderedText(field, msg1, WORD(LENGTH(10)), "The quick brown\nfox jumps over\nthe lazy dog,\nsupercal-aphraga\nlist-icexpiala-\ndocious");
		assertRenderedText(field, msg2, WORD(LENGTH(10)), "The quick brown\nfox jumps over\nthe lazy dog,\nsupercal-aphraga\nlist\nicexpiala-\ndocious");
		assertRenderedText(field, msg3, WORD(LENGTH(10)), "The quick brown\nfox jumps over\nthe lazy dog, su\npercalaphragalis\nticexpialadociou\ns");
	}
	
	@Test
	#if cpp @Ignore("Failing on cpp") #end
	function testFieldWidth()
	{
		final msg = "The quick brown fox jumps over the lazy dog";
		final text = new FlxBitmapText(0, 0, msg);
		Assert.areEqual(true, text.autoSize);
		Assert.areEqual(187, text.textWidth);
		Assert.areEqual(187, text.fieldWidth);
		assertRenderedText(text, msg); 
		
		text.fieldWidth = 80;
		Assert.areEqual(80, text.textWidth);
		Assert.areEqual(false, text.autoSize);
		assertRenderedText(text, msg, "The quick brown\nfox jumps over the\nlazy dog");
		
		text.fieldWidth = 0;
		Assert.areEqual(true, text.autoSize);
		Assert.areEqual(187, text.fieldWidth);
		Assert.areEqual(187, text.textWidth);
	}
	
	@Test
	#if cpp @Ignore("Failing on cpp") #end
	function testIsSpaceChar()
	{
		function assertSpaceChar(char:Int, ?msg, ?pos)
		{
			Assert.isTrue(FlxBitmapText.isSpaceChar(char), msg, pos);
		}
		
		final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789,./;\'[]\\<>?L:"{}|-=!@#$%^&*()_+';
		for (i in 0...chars.length)
		{
			if (FlxBitmapText.isSpaceChar(chars.charCodeAt(i)))
				Assert.fail('Expected isSpaceChar(${chars.charAt(i)}) to be false');
		}
		Assert.assertionCount++;
		
		final chars = ' \t';
		for (i in 0...chars.length)
		{
			if (FlxBitmapText.isSpaceChar(chars.charCodeAt(i)) == false)
				Assert.fail('Expected isSpaceChar(${chars.charAt(i)}) to be false');
		}
		Assert.assertionCount++;
	}
	
	overload inline extern function assertRenderedText(field:FlxBitmapText, ?wrap:FlxBitmapText.Wrap, expected:UnicodeString, ?pos:haxe.PosInfos)
	{
		assertRenderedTextHelper(field, null, wrap, expected, pos);
	}
	
	overload inline extern function assertRenderedText(field:FlxBitmapText, text:UnicodeString, ?wrap:FlxBitmapText.Wrap, expected:UnicodeString, ?pos:haxe.PosInfos)
	{
		assertRenderedTextHelper(field, text, wrap, expected, pos);
	}
	
	function assertRenderedTextHelper(field:FlxBitmapText, text:Null<UnicodeString>, ?wrap:Null<FlxBitmapText.Wrap>, expected:UnicodeString, ?pos:haxe.PosInfos)
	{
		if (wrap != null)
			field.wrap = wrap;
		
		final actual = field.getRenderedText(text != null ? text : field.text);
		Assert.areEqual(expected.split("\n").join("\\n"), actual.split("\n").join("\\n"), pos);
	}
}
