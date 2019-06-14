package;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;

class InstructionState extends FlxSubState
{
	override public function create():Void
	{
		bgColor = 0xAA000000;

		var t = new FlxText(0, 90, FlxG.width, "HeatmapPathfinding", 32);
		t.alignment = CENTER;
		add(t);

		var t2 = new FlxText(0, 170, FlxG.width, "Left Click: Place Wall\nRight Click: Erase Wall\nMiddle Click: Move McGuffin\nSpace: Add Seeker", 16);
		t2.alignment = CENTER;
		add(t2);

		var closeButton = new FlxButton(0, 300, "Ok", function() close());
		closeButton.screenCenter(FlxAxes.X);
		add(closeButton);
	}
}
