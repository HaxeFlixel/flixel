package;

import flixel.addons.nape.FlxPhysState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.plugin.MouseEventManager;
import flixel.util.FlxRandom;
import nape.constraint.DistanceJoint;
import nape.geom.Vec2;

/**
 * @author TiagoLr (~~~~ ProG4mr ~~~~)
 * Improvements by @author Gama11
 */
class PlayState extends FlxPhysState
{
	static public var cardJoint:DistanceJoint;
	
	private var _cardGroup:FlxTypedGroup<Card>;
	private var _fan:FlxSprite;
	
	override public function create():Void 
	{
		super.create();
		FlxG.mouse.show();
		
		// A table as a background
		add(new FlxSprite(0, 0, "assets/Table.jpg"));
		
		// We need the MouseEventManager plugin for sprite-mouse-interaction
		// Important to set this up before createCards()
		FlxG.plugins.add(new MouseEventManager());
		
		// Creating the card group and the cards
		_cardGroup = new FlxTypedGroup<Card>();
		createCards();
		add(_cardGroup);
		
		disablePhysDebug();
		createWalls();
		
		_fan = new FlxSprite(340, -280, "assets/Fan.png");
		_fan.antialiasing = true;
		// Let the fan spin at 10 degrees per second
		_fan.angularVelocity = 10;
		add(_fan);
	}
	
	private function createCards() 
	{
		// Creating the 10 cards in the middle
		for (i in 0...10)
		{
			var card:Card = new Card(230, 340, 20, -20, i);
			_cardGroup.add(card);
		}
		
		// Creating a stack of 7 cards in the upper left corner
		for (i in 0...7)
		{
			var card:Card = new Card(40, 50, 2, -2, i);
			_cardGroup.add(card);
		}
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		cardJoint = null;
		_cardGroup = null;
		_fan = null;
	}
	
	override public function update():Void 
	{
		super.update();
		
		if (cardJoint != null)
		{
			cardJoint.anchor1 = Vec2.weak(FlxG.mouse.x, FlxG.mouse.y);
		}
		
		// Remove the joint again if the mouse is not down
		if (FlxG.mouse.justReleased)
		{
			if (cardJoint == null)
			{
				return;
			}
			
			cardJoint.space = null;
			cardJoint = null;
		}
		
		// Keyboard hotkey to reset the state
		if (FlxG.keys.R)
		{
			FlxG.resetState();
		}
	}
}