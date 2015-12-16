package flixel.system.debug.completion;

import massive.munit.Assert;
using flixel.util.FlxArrayUtil;

class CompletionListTest extends FlxTest
{
	@Test
	function testSortItemsOrder()
	{
		var completionList = new CompletionList(3);
		completionList.show(0, ["replace", "_player", "player"]);
		completionList.filter = "pla";
		Assert.isTrue(["player", "_player", "replace"].equals(completionList.items));
	}
}