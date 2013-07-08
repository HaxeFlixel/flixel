package;

import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxPath;
import org.flixel.util.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxTilemap;
import org.flixel.system.FlxTile;

class PlayState extends FlxState
{
	var _level:FlxTilemap;
	var _player:Player;
	
	public function new()
	{
		super();
	}
	
	override public function create():Void
	{			
		//Background
		FlxG.bgColor = 0xffacbcd7;
		var decoration:FlxSprite = new FlxSprite(256, 159, "assets/bg.png");
		decoration.moves = false;
		decoration.solid = false;
		add(decoration);
		add(new FlxText(32, 36, 96, "collision").setFormat(null, 16, 0x778ea1, "center"));
		add(new FlxText(32, 60, 96, "DEMO").setFormat(null, 24, 0x778ea1, "center"));
		
		var path:FlxPath;
		var sprite:FlxSprite;
		var destination:FlxPoint;
		
		//Create the elevator and put it on a up and down path
		sprite = new FlxSprite(208, 80, "assets/elevator.png");
		sprite.immovable = true;
		destination = sprite.getMidpoint();
		destination.y += 112;
		path = new FlxPath([sprite.getMidpoint(),destination]);
		sprite.followPath(path, 40, FlxObject.PATH_YOYO);
		add(sprite);
		
		//Create the side-to-side pusher object and put it on a different path
		sprite = new FlxSprite(96, 208, "assets/pusher.png");
		sprite.immovable = true;
		destination = sprite.getMidpoint();
		destination.x += 56;
		path = new FlxPath([sprite.getMidpoint(),destination]);
		sprite.followPath(path,40,FlxObject.PATH_YOYO);
		add(sprite);
		
		//Then add the player, its own class with its own logic
		_player = new Player(32, 176);
		add(_player);
		
		//Then create the crates that are sprinkled around the level
		var crates:Array<FlxPoint> = [new FlxPoint(64,208),
							new FlxPoint(108,176),
							new FlxPoint(140,176),
							new FlxPoint(192,208),
							new FlxPoint(272,48)];
		for (i in 0...crates.length)
		{
			sprite = new FlxSprite(crates[i].x, crates[i].y, "assets/crate.png");
			sprite.height = sprite.height - 1;
			sprite.acceleration.y = 400;
			sprite.drag.x = 200;
			add(sprite);
		}
		
		//This is the thing that spews nuts and bolts
		var dispenser:FlxEmitter = new FlxEmitter(32, 40);
		dispenser.setSize(8,40);
		dispenser.setXSpeed(100,240);
		dispenser.setYSpeed(-50,50);
		dispenser.gravity = 300;
		dispenser.bounce = 0.3;
		dispenser.makeParticles("assets/gibs.png", 100, 16, true);
		dispenser.start(false, 10, 0.035);
		add(dispenser);
		
		//Basic level structure
		_level = new FlxTilemap();
		_level.loadMap(FlxTilemap.imageToCSV("assets/map.png", false, 2), "assets/tiles.png", 0, 0, FlxTilemap.ALT);
		_level.follow();
		add(_level);
		
		//Library label in upper left
		var tx:FlxText;
		tx = new FlxText(2, 0, Std.int(FlxG.width / 4), FlxG.getLibraryName());
		tx.scrollFactor.x = tx.scrollFactor.y = 0;
		tx.color = 0x778ea1;
		tx.shadow = 0x233e58;
		tx.useShadow = true;
		add(tx);
		
		//Instructions
		tx = new FlxText(2, FlxG.height - 12, FlxG.width, "Interact with ARROWS + SPACE, or press ENTER for next demo.");
		tx.scrollFactor.x = tx.scrollFactor.y = 0;
		tx.color = 0x778ea1;
		tx.shadow = 0x233e58;
		tx.useShadow = true;
		add(tx);
		
		/*part of silly path-finding test
		FlxG.mouse.show();
		FlxG.visualDebug = true;//*/
	}
	
	override public function destroy():Void
	{
		super.destroy();
		_level = null;
		_player = null;
	}
	
	override public function update():Void
	{
		/*silly path-finding test
		if(FlxG.mouse.justPressed())
		{
			var path:FlxPath = _level.findPath(_player.getMidpoint(),FlxG.mouse,true,true);
			if(path != null)
			{
				if(_player.path != null)
					_player.path.destroy();
				_player.followPath(path,80,FlxObject.PATH_FORWARD|FlxObject.PATH_HORIZONTAL_ONLY);
			}
		}//*/
		
		super.update();
		FlxG.collide();
		if(FlxG.keys.justReleased("ENTER"))
		{
			FlxG.switchState(new PlayState2());
		}
	}
}