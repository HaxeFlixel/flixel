package;

import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseEventManager;
import nape.constraint.DistanceJoint;
import nape.geom.Vec2;

/**
 * @author TiagoLr (~~~~ ProG4mr ~~~~)
 * Improvements by @author Gama11
 */
class PlayState extends FlxState
{
	public static var cardJoint:DistanceJoint;
	
	private var fan:FlxSprite;
	
	override public function create():Void
	{
		FlxNapeSpace.init();
		
		// A table as a background
		add(new FlxSprite(0, 0, "assets/Table.jpg"));
		
		// We need the FlxMouseEventManager plugin for sprite-mouse-interaction
		// Important to set this up before createCards()
		FlxG.plugins.add(new FlxMouseEventManager());
		
		// Creating the card group and the cards
		add(createCards());

		FlxNapeSpace.createWalls();
		
		fan = new FlxSprite(340, -280, "assets/Fan.png");
		fan.antialiasing = true;
		// Let the fan spin at 10 degrees per second
		fan.angularVelocity = 10;
		add(fan);
	}

	private function createCards():FlxTypedGroup<Card>
	{
		var cards = new FlxTypedGroup<Card>();
		var pickedCards = [];

		function createCardStack(amount:Int, start:FlxPoint, offset:FlxPoint)
		{
			var x = start.x;
			var y = start.y;

			for (i in 0...amount)
			{
				// Choose a random card from the first 52 cards on the spritesheet 
				// - excluding those who have already been picked!
				var pick = FlxG.random.int(0, 51, pickedCards);
				cards.add(new Card(x, y, pick));

				x += offset.x;
				y += offset.y;
			}
		}

		// Creating a stack of 7 cards in the upper left corner
		createCardStack(7, FlxPoint.get(40, 50), FlxPoint.get(2, -2));

		// Creating the 10 cards in the middle
		createCardStack(10, FlxPoint.get(230, 340), FlxPoint.get(20, -20));

		return cards;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (cardJoint != null)
			cardJoint.anchor1 = Vec2.weak(FlxG.mouse.x, FlxG.mouse.y);
		
		// Remove the joint again if the mouse is not down
		if (FlxG.mouse.justReleased)
		{
			if (cardJoint == null)
				return;
			
			cardJoint.space = null;
			cardJoint = null;
		}
		
		// Keyboard hotkey to reset the state
		if (FlxG.keys.pressed.R)
			FlxG.resetState();
	}
}