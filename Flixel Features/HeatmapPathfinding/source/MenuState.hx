package ;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

/**
 * ...
 * @author 
 */
class MenuState extends FlxState
{

	public function new() 
	{
		super();
	}
	
	public override function create():Void {
		var t:FlxText = new FlxText(0, 10, FlxG.width, "Many-to-one Pathfinding Test");
		t.alignment = "center";
		add(t);
		
		var t2 = new FlxText(50, 60, FlxG.width, "Left Click: Place Wall\nRight Click: Erase Wall\nMiddle Click: Move McGuffin\nSpace: Add Seeker\n\nPress ENTER to start");
		add(t2);
	}
	
	public override function update():Void {
		super.update();
		if (FlxG.keys.justPressed.ENTER) {
			FlxG.switchState(new PlayState());
		}
	}
	
}