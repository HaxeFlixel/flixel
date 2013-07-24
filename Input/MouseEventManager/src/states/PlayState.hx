package states;
import nape.constraint.DistanceJoint;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxPhysSprite;
import flixel.addons.nape.FlxPhysState;
import flixel.plugin.MouseEventManager;
#if flash
#end

/**
 * @author TiagoLr (~~~~ ProG4mr ~~~~)
 */

class PlayState extends FlxPhysState
{
	var cardJoint:DistanceJoint;
	var cards:Array<FlxPhysSprite>;
	var fan:FlxSprite;
	
	override public function create():Void 
	{
		super.create();
		
		add(new FlxSprite(0, 0, Assets.getBitmapData("assets/Table.jpg")));
		cards = new Array<FlxPhysSprite>();
		
		disablePhysDebug();
		//#if !neko
			//FlxG.bgColor = 0xFF01355F;
		//#else
			//FlxG.camera.bgColor = {rgb: 0x01355F, a: 0xFF};
		//#end
		
		FlxG.mouse.show();
		
		FlxG.plugins.add(new MouseEventManager());
		
		createWalls();
		createCards();
		
		fan = new FlxSprite(340, -280, Assets.getBitmapData("assets/Fan.png"));
		fan.antialiasing = true;
		MouseEventManager.addSprite(fan, null,null, onOverSprite, onOutSprite);
		add(fan);
	}
	
	private function createCards() 
	{
		for (i in 0...10)
		{
			createCard(230, 340, 20, 20, i);
		}
		
		for (i in 0...7)
		{
			createCard(40, 50, 2, 2, i);
		}
		
	}
	
	private function createCard(startX:Int, startY:Int, offsetX:Int, offsetY:Int, i:Int):Void 
	{
		var spr:FlxPhysSprite = new FlxPhysSprite(startX + offsetX * i , startY - offsetY * i);
		spr.makeGraphic(40, 80, 0xFFFF0000);
		spr.loadGraphic(Assets.getBitmapData("assets/Deck.png"), true, false, 123, 123);
		spr.createRectangularBody(79,123);
		spr.body.setShapeFilters(new InteractionFilter(2, ~2));
		spr.frame = 54;
		spr.antialiasing = true;
		spr.setDrag(0.95, 0.95);
		add(spr);
		
		cards.push(spr);
		MouseEventManager.addSprite(spr, onMouseDown, null, onOverSprite, onOutSprite);
	}
	
	public function onOverSprite(spr:FlxSprite) 
	{
		spr.color = 0x00FF00;
	}
	
	public function onOutSprite(spr:FlxSprite)
	{
		
		spr.color = 0x00FFFFFF;
	}
	
	public function onMouseDown(spr:FlxSprite)
	{
		if (spr.scale.x == 1) 
			spr.scale.x -= 0.0001;
		
		var body = cast(spr, FlxPhysSprite).body;
		
		cardJoint = new DistanceJoint(FlxPhysState.space.world, body, new Vec2(FlxG.mouse.x, FlxG.mouse.y),
						body.worldPointToLocal(new Vec2(FlxG.mouse.x, FlxG.mouse.y)), 0, 0);
						
		cardJoint.stiff 	= false;
		//cardJoint.maxForce = 100;
		cardJoint.damping = 1;
		cardJoint.frequency = 2;
		cardJoint.space	= FlxPhysState.space;
	}
	
	override public function update():Void 
	{
		super.update();
		
		if (cardJoint != null)
		{
			cardJoint.anchor1 = new Vec2(FlxG.mouse.x, FlxG.mouse.y);
		}
		
		// Card animation
		for (card in cards)
		{
			if (card.scale.x != 1)
			{
				if (card.frame == 54)
					card.scale.x -= 20 * FlxG.elapsed;
				else 
					card.scale.x += 20 * FlxG.elapsed;
			}
			if (card.scale.x <= 0 && card.frame == 54)
			{
				card.scale.x = 0;
				card.frame = Std.int(Math.random() * 52);
			}
			if (card.scale.x >= 1) 
			{
				card.scale.x = 1;
			}
		}
		//
		fan.angle += 10 * FlxG.elapsed;
		
		if (FlxG.mouse.justReleased())
		{
			if (cardJoint == null)
				return;
			cardJoint.space = null;
			cardJoint = null;
		}
		
		if (FlxG.keys.justPressed("R"))
			FlxG.resetState();
		
		
	}
	
}