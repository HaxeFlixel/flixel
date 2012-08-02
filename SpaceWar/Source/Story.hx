package;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;

class Story extends FlxState 
{
	private var exit:FlxButton;
	private var back:FlxButton;
	
	override public function create():Void 
	{
		var title:FlxText;
		title = new FlxText(0, 16, FlxG.width, "Space War");
		title.setFormat(null, 16, 0xFFFFFF, "center");
		add(title);
		
		var story:FlxText;
		story = new FlxText(0, 200, FlxG.width, "Welcome to Space War! It's game about EBDD - Experemental Battle Droid for Destroing, small AI ship. Earth was attacked by Zorgs - aliens from 0x000000001 galaxy. You, yes, you, control EBDD, and you must defend Earth. Avoid Zorgs, and destroy it, up your score, and save Earth!");
		story.setFormat(null, 8, 0xFFFFFF, "center");
		add(story);
		
		back = new FlxButton(275, 250, "Back", backToMenu);
		add(back);
	}
	
	public function new() 
	{
		super();
	}
	
	public function backToMenu():Void 
	{	
		FlxG.switchState(new MenuState());	
	}
}