package;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;

class Credits extends FlxState 
{
	var back:FlxButton;
	
	override public function create():Void 
	{
		var title:FlxText;
		title = new FlxText(0, 16, FlxG.width, "Space War");
		title.setFormat(null, 16, 0xFFFFFF, "center");
		add(title);
		
		var credits:FlxText;
		credits = new FlxText(0, 200, FlxG.width, "Programming - Ilya, Zorg Sprites - Ilya, Ship Sprite - fred-sable, sounds - Andreas Zecher's Tutorials, music and Nyaaaaaaan Sprites - Nyan Cat, Die Anyway by SGX. Big thanks to Adam Atomic for wonderful Flixel framework!");
		credits.setFormat(null, 8, 0xFFFFFF, "center");
		add(credits);
		
		back = new FlxButton(275, 300, "Back", backToMenu);
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