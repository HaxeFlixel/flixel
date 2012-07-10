package;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;


class MenuState extends FlxState
{
	
	public function new()
	{
		super();
	}
	
	override public function create():Void
	{
		var t:FlxText;
		t = new FlxText(0, FlxG.height / 2 - 20, FlxG.width, "Path Finding Demo");
		t.size = 32;
		t.alignment = "center";
		add(t);
		t = new FlxText(FlxG.width / 2 - 100, FlxG.height - 30, 200, "click to test");
		t.size = 16;
		t.alignment = "center";
		add(t);
		
		FlxG.mouse.show();
	}

	override public function update():Void
	{
		super.update();

		if (FlxG.mouse.justPressed())
		{
			FlxG.switchState(new PlayState());
		}
	}
}
