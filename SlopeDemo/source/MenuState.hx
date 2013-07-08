package;
import org.flixel.FlxButton;
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
		FlxG.bgColor = 0xff050510;
		
		var text:FlxText;
		text = new FlxText(FlxG.width / 2 - 100, FlxG.height / 3 - 30, 200, "Slope Demo");
		text.alignment = "center";
		text.color = 0x9999ff;
		text.size = 20;
		add(text);

		text = new FlxText(FlxG.width / 2 - 50, FlxG.height / 3, 200, "by Peter Christiansen");
		text.alignment = "center";
		text.color = 0x9999ff;
		add(text);
		
		var startButton:FlxButton = new FlxButton(FlxG.width / 2 - 40, FlxG.height / 3 + 64, "Play", onPlay);
		startButton.color = 0x666699;
		startButton.label.color = 0x9999ff;
		add(startButton);
		
		FlxG.mouse.show("assets/cursor.png", 2);
	}
	
	private function onPlay():Void
	{
		FlxG.switchState(new PlayState());
	}
}