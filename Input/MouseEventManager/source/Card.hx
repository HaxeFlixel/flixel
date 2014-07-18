package;

import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.math.FlxRandom;
import nape.constraint.DistanceJoint;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;

class Card extends FlxNapeSprite
{
	/**
	 * How long the turning animation takes
	 */
	private static inline var TURNING_TIME:Float = 0.2;
	
	/**
	 * This is a helper Array to keep track of the cards that have 
	 * been picked so far, to avoid the same card being shown twice!
	 */
	public static var pickedCards:Array<Int> = new Array<Int>();
	
	/**
	 * Whether the card has been turned around yet or not
	 */
	private var _turned:Bool = false;
	
	public function new(X:Int, Y:Int, OffsetX:Int, OffsetY:Int, Index:Int):Void
	{
		super(X + OffsetX * Index, Y + OffsetY * Index);
		loadGraphic("assets/Deck.png", true, 79, 123);
		
		// The card starts out being turned around
		animation.frameIndex = 54;
		// So the card still looks smooth when rotated
		antialiasing = true;
		setDrag(0.95, 0.95);
		// Creating a nape body
		createRectangularBody(79, 123);
		// To make sure cards don't interact with each other
		body.setShapeFilters(new InteractionFilter(2, ~2));
		
		// Setup the mouse events
		FlxMouseEventManager.add(this, onDown, null, onOver, onOut);
	}
	
	private function onDown(Sprite:FlxSprite)
	{
		// Play the turning animation if the card hasn't been turned around yet
		if (!_turned)
		{
			_turned = true;
			FlxTween.tween(scale, { x: 0 }, TURNING_TIME / 2, { complete: pickCard });
		}
		
		var body:Body = cast(Sprite, FlxNapeSprite).body;
		
		PlayState.cardJoint = new DistanceJoint(FlxNapeState.space.world, body, Vec2.weak(FlxG.mouse.x, FlxG.mouse.y),
						body.worldPointToLocal(Vec2.weak(FlxG.mouse.x, FlxG.mouse.y)), 0, 0);
						
		PlayState.cardJoint.stiff = false;
		PlayState.cardJoint.damping = 1;
		PlayState.cardJoint.frequency = 2;
		PlayState.cardJoint.space = FlxNapeState.space;
	}
	
	
	private function onOver(Sprite:FlxSprite) 
	{
		color = 0x00FF00;
	}
	
	private function onOut(Sprite:FlxSprite)
	{
		color = FlxColor.WHITE;
	}
	
	private function pickCard(Tween:FlxTween):Void
	{
		// Choose a random card from the first 52 cards on the spritesheet 
		// - excluding those who have already been picked!
		animation.frameIndex = FlxG.random.int(0, 51, pickedCards);
		pickedCards.push(animation.frameIndex);
		
		// Finish the card animation
		FlxTween.tween(scale, { x: 1 }, TURNING_TIME / 2);
	}
	
	override public function destroy():Void 
	{
		// Make sure that this object is removed from the FlxMouseEventManager for GC
		FlxMouseEventManager.remove(this);
		super.destroy();
	}
}
