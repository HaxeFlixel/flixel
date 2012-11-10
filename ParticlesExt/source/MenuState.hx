package;

import flash.ui.Mouse;
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
		//For the purposes of the demo we'll have the framerate ultra low
		//so that we don't eat processor power away from any other SWF's on the page.
		FlxG.framerate = 10;
		FlxG.flashFramerate = 10;
		
		var t:FlxText;
		t = new FlxText(0,FlxG.height/2-40,FlxG.width,"Collision and\n Grouping Demo");
		t.size = 32;
		t.alignment = "center";
		add(t);
		t = new FlxText(FlxG.width/2-100,FlxG.height-30,200,"click to test");
		t.size = 16;
		t.alignment = "center";
		add(t);
		
		//The Flixel mouse cursor looks awfully laggy with the framerate
		//so low, so we'll hide it away.
		FlxG.mouse.hide();
		Mouse.show();
	}

	override public function update():Void
	{
		super.update();
		
		if(FlxG.mouse.justPressed())
		{
			FlxG.switchState(new PlayState());
		}
	}
}
