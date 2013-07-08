package;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;

class ControlsSelect extends FlxState 
{
	
	public static var control:String;
	private var mouseControl:FlxButton;
	private var keyboardControl:FlxButton;
	
	override public function create():Void 
	{	
		FlxG.mouse.show();
		
		var title:FlxText;
		title = new FlxText(0, 16, FlxG.width, "Space War");
		title.setFormat(null, 16, 0xFFFFFF, "center");
		add(title);
		
		var mouse:FlxText;
		mouse = new FlxText(0, 100, FlxG.width, "Keyboard Controls - Arrow Keys to Move, Space to Shoot. Mouse Controls - Drag Mouse to Move, Click to Shoot.");
		mouse.setFormat(null, 8, 0xFFFFFF, "center");
		add(mouse);
		
		mouseControl = new FlxButton(100, 235, "Mouse", mouseControls);
		add(mouseControl);
	
		keyboardControl = new FlxButton(445, 235, "Keyboard", keyboardControls);
		add(keyboardControl);
		
	}
	
	public function new() 
	{
		super();
	}
	
	private function mouseControls():Void 
	{
		control = "mouse";
		FlxG.switchState(new ModeSelect());
	}
	
	private function keyboardControls():Void 
	{	
		control = "keyboard";
		FlxG.switchState(new ModeSelect());	
	}
}