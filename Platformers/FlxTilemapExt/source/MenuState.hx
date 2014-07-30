package;

import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class MenuState extends FlxState
{
	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff050510;
		FlxG.mouse.load("assets/cursor.png", 2);
		
		var text:FlxText;
		text = new FlxText(FlxG.width / 2 - 100, FlxG.height / 3 - 30, 200, "Slope Demo");
		text.setFormat(null, 20, 0xFFFFFFFF, CENTER);
		add(text);
		
		text = new FlxText(FlxG.width / 2 - 50, FlxG.height / 3, 200, "by Peter Christiansen");
		text.setFormat(null, 8, 0xFFFFFFFF, CENTER);
		add(text);
		
		var startButton:FlxButton = new FlxButton(FlxG.width / 2 - 40, FlxG.height / 3 + 64, "Play", onPlay);
		startButton.color = 0x666699;
		startButton.label.color = 0xFFFFFFFF;
		add(startButton);
	}
	
	private function onPlay():Void
	{
		FlxG.switchState(new PlayState());
	}
}