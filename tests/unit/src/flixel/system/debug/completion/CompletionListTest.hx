package flixel.system.debug.completion;

class CompletionListTest extends FlxTest
{
	@Test
	function testSortItemsOrder()
	{
		var completionList = new CompletionList(3);
		completionList.show(0, ["replace", "_player", "player"]);
		completionList.filter = "pla";
		FlxAssert.arraysEqual(["player", "_player", "replace"], completionList.items);
	}
}
