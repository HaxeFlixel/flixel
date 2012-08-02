package;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;

class MenuState extends FlxState 
{
	
	private var playGame:FlxButton;
	private var story:FlxButton;
	private var credits:FlxButton;
	
	override public function create():Void 
	{
		var title:FlxText;
		title = new FlxText(0, 16, FlxG.width, "Space War");
		title.setFormat(null, 16, 0xFFFFFF, "center");
		add(title);
		
		var version:FlxText;
		version = new FlxText(0, 0, FlxG.width, "Big Update Pre Release");
		version.setFormat(null, 8, 0xFFFFFF, "left");
		add(version);
		
		playGame = new FlxButton(275, 200, "Quick Play", play);
		add(playGame);
		
		story = new FlxButton(275, 235, "Story", storyLine);
		add(story);
		
		credits = new FlxButton(275, 275, "Credits", creditsGo);
		add(credits);
		
	}
	
	override public function update():Void 
	{
		super.update();
	}
	
	public function new() 
	{
		super();
		FlxG.mouse.show();
	}
	
	private function play():Void 
	{
		FlxG.switchState(new ControlsSelect());
	}
	
	private function storyLine():Void 
	{
		FlxG.switchState(new Story());
	}
	
	private function creditsGo():Void 
	{
		FlxG.switchState(new Credits());
	}
}