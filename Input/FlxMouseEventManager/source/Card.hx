package;

import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
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
	 * Whether the card has been turned around yet or not
	 */
	private var turned:Bool = false;

	/**
	 * Which card this is (index in the sprite sheet).
	 */
	private var cardIndex:Int;
	
	public function new(x:Float, y:Float, cardIndex:Int):Void
	{
		super(x, y);
		this.cardIndex = cardIndex;
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
	
	private function onDown(_)
	{
		// Play the turning animation if the card hasn't been turned around yet
		if (!turned)
		{
			turned = true;
			FlxTween.tween(scale, { x: 0 }, TURNING_TIME / 2, { onComplete: pickCard });
		}
		
		PlayState.cardJoint = new DistanceJoint(FlxNapeSpace.space.world, body, Vec2.weak(FlxG.mouse.x, FlxG.mouse.y),
			body.worldPointToLocal(Vec2.weak(FlxG.mouse.x, FlxG.mouse.y)), 0, 0);
		
		PlayState.cardJoint.stiff = false;
		PlayState.cardJoint.damping = 1;
		PlayState.cardJoint.frequency = 2;
		PlayState.cardJoint.space = FlxNapeSpace.space;
	}
	
	private function onOver(_)
	{
		color = 0x00FF00;
	}
	
	private function onOut(_)
	{
		color = FlxColor.WHITE;
	}
	
	private function pickCard(_):Void
	{
		animation.frameIndex = cardIndex;
		
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
