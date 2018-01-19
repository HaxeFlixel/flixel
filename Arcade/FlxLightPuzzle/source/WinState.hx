package;

import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

/**
 * A substate that appears once the player wins the game.
 * @author MSGhero
 */
class WinState extends FlxSubState
{
	var winMessage:FlxText;
	
	override public function create():Void
	{
		var bg = ColorMaps.defaultColorMap.get(Color.WHITE) == FlxColor.BLACK ? FlxColor.WHITE : FlxColor.BLACK; // if the background is black, we want white text, and vice-versa
		
		winMessage = new FlxText(256, 40, 250, "Want more?\n\nYou can copy the code to make more levels or change it however you want.\n\n" +
			"This project is open source and released under MIT license thanks to HaxeFlixel supporters.\n\n" +
			"Grab the code and become a HaxeFlixel supporter to help make more cool open-source demos like this."
		, 14);
		winMessage.setFormat(null, 12, bg);
		winMessage.alignment = "center";
		
		// delay to match up with the expanding circle background
		new FlxTimer().start(1.25, addWinMessage);
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		if (winMessage != null)
		{
			winMessage.destroy();
			winMessage = null;
		}
	}
	
	function addWinMessage(_):Void
	{
		if (winMessage != null) // this check is for the off-chance someone hits the reset button before the message shows up
			add(winMessage);
	}
}