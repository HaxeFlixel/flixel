package org.flixel.addons;

import org.flixel.FlxTypedGroup;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;

/**
 * Nothing too fancy, just a handy little class to attach a trail effect to a FlxSprite.
 * Inspired by the way "Buck" from the inofficial #flixel IRC channel 
 * creates a trail effect for the character in his game.
 * Feel free to use this class and adjust it to your needs.
 * 
 * @author Gama11
 */
class FlxTrail extends FlxTypedGroup<FlxSprite>
{		
	/**
	 *  Stores the FlxSprite the trail is attached to.
	 */
	public var sprite:FlxSprite;
	/**
	 *  How often to update the trail.
	 */
	public var delay:Int;
	/**
	 *  Whether to check for X changes or not.
	 */
	public var xEnabled:Bool = true;
	/**
	 *  Whether to check for Y changes or not.
	 */
	public var yEnabled:Bool = true;
	/**
	 *  Whether to check for angle changes or not.
	 */
	public var rotationsEnabled:Bool = true;
	/**
	 *  Counts the frames passed.
	 */
	private var counter:Int = 0;
	/**
	 *  How long is the trail?
	 */
	private var trailLength:Int = 0;
	/**
	 *  Stores the trailsprite image.
	 */
	private var image:Dynamic;
	/**
	 *  The alpha value for the next trailsprite.
	 */
	private var transp:Float = 1;
	/**
	 *  How much lower the alpha value of the next trailsprite is.
	 */
	private var difference:Float;
	/**
	 *  Stores the sprites recent positions.
	 */
	private var recentPositions:Array<FlxPoint>;
	/**
	 *  Stores the sprites recent angles.
	 */
	private var recentAngles:Array<Float>;

	/**
	 * Creates a new <code>FlxTrail</code> effect for a specific FlxSprite.
	 * 
	 * @param	Sprite		The FlxSprite the trail is attached to.
	 * @param	Image		The image to ues for the trailsprites.
	 * @param	Length		The amount of trailsprites to create. 
	 * @param	Delay		How often to update the trail. 0 updates every frame.
	 * @param	Alpha		The alpha value for the very first trailsprite.
	 * @param	Diff		How much lower the alpha of the next trailsprite is.
	 */
	override public function new(Sprite:FlxSprite, Image:Dynamic, Length:Int = 10, Delay:Int = 3, Alpha:Float = 0.4, Diff:Float = 0.05):Void
	{
		super();

		recentAngles = new Array<Float>();
		recentPositions = new Array<FlxPoint>();

		// Sync the vars 
		sprite = Sprite;
		delay = Delay;
		image = Image;
		transp = Alpha;
		difference = Diff;

		// Create the initial trailsprites
		increaseLength(Length);
	}		

	/**
	 * Updates positions and other values according to the delay that has been set.
	 * 
	 */
	override public function postUpdate():Void
	{
		// Count the frames
		counter++;

		// Update the trail in case the intervall and there actually is one.
		if (counter >= delay && trailLength >= 1)
		{
			counter = 0;

			// Push the current position into the positons array and drop one.
			var spritePosition:FlxPoint = new FlxPoint(sprite.x - sprite.offset.x, sprite.y - sprite.offset.y);
			recentPositions.unshift(spritePosition);
			if (recentPositions.length > trailLength) recentPositions.pop();

			// Also do the same thing for the Sprites angle if rotationsEnabled 
			if (rotationsEnabled) 
			{
				var spriteAngle:Float = sprite.angle;
				recentAngles.unshift(spriteAngle);
				if (recentAngles.length > trailLength) recentAngles.pop();
			}

			// Now we need to update the all the Trailsprites' values
			var trailSprite:FlxSprite;
			for (i in 0 ... recentPositions.length) 
			{
				trailSprite = members[i];
				trailSprite.x = recentPositions[i].x;
				trailSprite.y = recentPositions[i].y;
				// And the angle...
				if (rotationsEnabled) trailSprite.angle = recentAngles[i];

				// Is the trailsprite even visible?
				trailSprite.exists = true; 
			}
		}

		super.update();
	}

	public function resetTrail():Void
	{
		recentPositions.splice(0, recentPositions.length);
		recentAngles.splice(0, recentAngles.length);
		for (i in 0...members.length) 
			members[i].exists = false;
	}

	/**
	 * A function to add a specific number of sprites to the trail to increase its length.
	 *
	 * @param 	amount	The amount of sprites to add to the trail.
	 */
	public function increaseLength(amount:Int):Void
	{
		// Can't create less than 1 sprite obviously
		if (amount <= 0) return;

		trailLength += amount;

		// Create the trail sprites
		for (i in 0...amount)
		{
			var trailSprite:FlxSprite = new FlxSprite(0, 0, image);
			trailSprite.exists = false;
			add(trailSprite);
			trailSprite.alpha = transp;
			transp -= difference;

			if (trailSprite.alpha <= 0) trailSprite.kill();
		}	
	}

	/**
	 * In case you want to change the trailsprite image in runtime...
	 *
	 * @param 	Image	The image the sprites should load
	 */
	public function changeGraphic(Image:Dynamic):Void
	{
		image = Image;

		for (i in 0...trailLength)
		{
			members[i].loadGraphic(Image);
		}	
	}

	/**
	 * Handy little function to change which events affect the trail.
	 *
	 * @param 	Angle 	Whether the trail reacts to angle changes or not.
	 * @param 	X 		Whether the trail reacts to x changes or not.
	 * @param 	Y 		Whether the trail reacts to y changes or not.
	 */
	public function changeValuesEnabled(Angle:Bool, X:Bool = true, Y:Bool = true):Void
	{
		rotationsEnabled = Angle;
		xEnabled = X;
		yEnabled = Y;
	}
}