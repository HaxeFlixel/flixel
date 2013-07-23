package;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;

class MenuState extends FlxState
{
	override public function create():Void
	{
		var t:FlxText;
		t = new FlxText(0, FlxG.height / 2 - 10, FlxG.width, "JukioJams");
		t.size = 16;
		t.alignment = "center";
		add(t);
		t = new FlxText(FlxG.width / 2 - 50, FlxG.height - 20, 100, "click to play");
		t.alignment = "center";
		add(t);
		
		FlxG.mouse.show();
	}

	override public function update():Void
	{
		super.update();

		if(FlxG.mouse.justPressed())
		{
			FlxG.mouse.hide();
			FlxG.switchState(new PlayState());
		}
	}
}