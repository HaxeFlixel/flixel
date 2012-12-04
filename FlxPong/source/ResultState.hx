package;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;
class ResultState extends FlxState 
{
	override public function create():Void 
	{
		super.create();
		var t:FlxText = new FlxText(0, (FlxG.height / 2 ) + 24, FlxG.width, "Press Enter");
		t.alignment = "center";
		t.flicker( -1);
		add(t);
		
		if (PlayState.pScoreLiteral >= PlayState.scoreCap) 
		{
			var x:FlxText = new FlxText(0, FlxG.height /2 , FlxG.width, "Player 1 is victorious!!!");
			x.alignment = "center";
			add(x);
			PlayState.pScoreLiteral = 0;
			PlayState.eScoreLiteral = 0;
		}
		
		if (PlayState.eScoreLiteral >= PlayState.scoreCap) 
		{
			var f:FlxText = new FlxText(0, FlxG.height / 2, FlxG.width, "Player 2 is victorious!!!");
			f.alignment = "center";
			add(f);
			PlayState.eScoreLiteral = 0;
			PlayState.pScoreLiteral = 0;
		}
	}
	
	override public function update():Void 
	{
		super.update();
		
		if (FlxG.keys.ENTER) 
		{
			MenuState.isNewGame = true;
			FlxG.switchState(new MenuState());
		}
	}
}