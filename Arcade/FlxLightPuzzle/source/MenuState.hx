package;

import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * The "main menu" state for the player to select their color palette.
 * @author MSGHero
 */
class MenuState extends FlxSubState
{
	var title:FlxText;

	var playRYB:FlxSprite;
	var playRGB:FlxSprite;
	var playCMY:FlxSprite;

	override public function create():Void
	{
		title = new FlxText(50, 10, 512 - 50, "FlxLightPuzzle", 20);
		title.color = FlxColor.WHITE;
		title.alignment = "center";
		add(title);

		// barsHorizontal.png from Kenney.nl were colored to make them more appropriate for this game

		playRYB = new FlxSprite(300, 72 - 25, AssetPaths.ryb__png);
		FlxMouseEventManager.add(playRYB, null, onSelect, onMOver, onMOut, false, true, false);
		FlxMouseEventManager.setMouseClickCallback(playRYB, onSelect);
		add(playRYB);

		playRGB = new FlxSprite(300, 144 - 25, AssetPaths.rgb__png);
		FlxMouseEventManager.add(playRGB, null, onSelect, onMOver, onMOut, false, true, false);
		FlxMouseEventManager.setMouseClickCallback(playRGB, onSelect);
		add(playRGB);

		playCMY = new FlxSprite(300, 216 - 25, AssetPaths.cmy__png);
		FlxMouseEventManager.add(playCMY, null, onSelect, onMOver, onMOut, false, true, false);
		FlxMouseEventManager.setMouseClickCallback(playCMY, onSelect);
		add(playCMY);
	}

	override public function destroy():Void
	{
		if (title != null)
		{
			title.destroy();
			title = null;
		}

		if (playRYB != null)
		{
			playRYB.destroy();
			playRYB = null;
		}

		if (playRGB != null)
		{
			playRGB.destroy();
			playRGB = null;
		}

		if (playCMY != null)
		{
			playCMY.destroy();
			playCMY = null;
		}
	}

	function onSelect(target:FlxSprite):Void
	{
		ColorMaps.defaultColorMap = if (target == playRYB) ColorMaps.rybMap else if (target == playRGB) ColorMaps.rgbMap else ColorMaps.cmyMap;

		FlxMouseEventManager.remove(playRYB); // onMOut will trigger after the menu substate is removed (and after the play buttons are destroyed) without this, causing an error
		FlxMouseEventManager.remove(playRGB);
		FlxMouseEventManager.remove(playCMY);

		close(); // close the menu state and let the game commence
	}

	function onMOver(target:FlxSprite):Void
	{
		// make the buttons more noticeable by expanding them on mouse over
		target.scale.x = 1.25;
		target.scale.y = 1.25;
	}

	function onMOut(target:FlxSprite):Void
	{
		target.scale.x = 1;
		target.scale.y = 1;
	}
}
