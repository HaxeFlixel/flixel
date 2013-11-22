package flixel.effects;

import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxPoint;

/**
 * Nothing too fancy, just a handy little class to attach a trail effect to a FlxSprite.
 * Inspired by the way "Buck" from the inofficial #flixel IRC channel 
 * creates a trail effect for the character in his game.
 * Feel free to use this class and adjust it to your needs.
 * @author Gama11
 */
class FlxTrail extends FlxTypedGroup<FlxSprite>
{		
	/**
	 * Stores the FlxSprite the trail is attached to.
	 */
	public var sprite:FlxSprite;
	/**
	 * How often to update the trail.
	 */
	public var delay:Int;
	/**
	 * Whether to check for X changes or not.
	 */
	public var xEnabled:Bool = true;
	/**
	 * Whether to check for Y changes or not.
	 */
	public var yEnabled:Bool = true;
	/**
	 * Whether to check for angle changes or not.
	 */
	public var rotationsEnabled:Bool = true;
	/**
	 * Whether to check for scale changes or not.
	 */
	public var scalesEnabled:Bool = true;
	/**
	 * Whether to check for frame changes of the "parent" FlxSprite or not.
	 */
	public var framesEnabled:Bool = true;
	
	/**
	 *  Counts the frames passed.
	 */
	private var _counter:Int = 0;
	/**
	 *  How long is the trail?
	 */
	private var _trailLength:Int = 0;
	/**
	 *  Stores the trailsprite image.
	 */
	private var _image:Dynamic;
	/**
	 *  The alpha value for the next trailsprite.
	 */
	private var _transp:Float = 1;
	/**
	 *  How much lower the alpha value of the next trailsprite is.
	 */
	private var _difference:Float;
	/**
	 *  Stores the sprites recent positions.
	 */
	private var _recentPositions:Array<FlxPoint>;
	/**
	 *  Stores the sprites recent angles.
	 */
	private var _recentAngles:Array<Float>;
	/**
	 *  Stores the sprites recent scale.
	 */
	private var _recentScales:Array<FlxPoint>;
	/**
	 *  Stores the sprites recent frame.
	 */
	private var _recentFrames:Array<Int>;
	/**
	 *  Stores the sprites recent facing.
	 */
	private var _recentFacings:Array<Int>;
	/**
	 *  Stores the sprite origin (rotation axis)
	 */
	private var _spriteOrigin:FlxPoint;
	
	/**
	 * Creates a new <code>FlxTrail</code> effect for a specific FlxSprite.
	 * 
	 * @param	Sprite		The FlxSprite the trail is attached to.
	 * @param  	Image   	The image to ues for the trailsprites. Optional, uses the sprite's graphic if null.
	 * @param	Length		The amount of trailsprites to create. 
	 * @param	Delay		How often to update the trail. 0 updates every frame.
	 * @param	Alpha		The alpha value for the very first trailsprite.
	 * @param	Diff		How much lower the alpha of the next trailsprite is.
	 */
	public function new(Sprite:FlxSprite, ?Image:Dynamic, Length:Int = 10, Delay:Int = 3, Alpha:Float = 0.4, Diff:Float = 0.05):Void
	{
		super();

		_recentAngles = new Array<Float>();
		_recentPositions = new Array<FlxPoint>();
		_recentScales = new Array<FlxPoint>();
		_recentFrames = new Array<Int>();
		_recentFacings = new Array<Int>();
		_spriteOrigin = new FlxPoint(Sprite.origin.x, Sprite.origin.y);

		// Sync the vars 
		sprite = Sprite;
		delay = Delay;
		_image = Image;
		_transp = Alpha;
		_difference = Diff;

		// Create the initial trailsprites
		increaseLength(Length);
		solid = false;
	}
	
	override public function destroy():Void
	{
		_recentAngles = null;
		_recentPositions = null;
		_recentScales = null;
		_recentFrames = null;
		_recentFacings = null;
		_spriteOrigin = null;

		sprite = null;
		_image = null;
		
		super.destroy();
	}

	/**
	 * Updates positions and other values according to the delay that has been set.
	 * 
	 */
	override public function update():Void
	{
		// Count the frames
		_counter++;

		// Update the trail in case the intervall and there actually is one.
		if (_counter >= delay && _trailLength >= 1)
		{
			_counter = 0;
			
			// Push the current position into the positons array and drop one.
			var spritePosition:FlxPoint = null;
			if (_recentPositions.length == _trailLength)
			{
				spritePosition = _recentPositions.pop();
			}
			else
			{
				spritePosition = new FlxPoint();
			}
			
			spritePosition.set(sprite.x - sprite.offset.x, sprite.y - sprite.offset.y);
			_recentPositions.unshift(spritePosition);
			
			// Also do the same thing for the Sprites angle if rotationsEnabled 
			if (rotationsEnabled) 
			{
				var spriteAngle:Float = sprite.angle;
				_recentAngles.unshift(spriteAngle);
				
				if (_recentAngles.length > _trailLength) 
				{
					_recentAngles.pop();
				}
			}
			
			// Again the same thing for Sprites scales if scalesEnabled
			if (scalesEnabled)
			{
				var spriteScale:FlxPoint = null; // sprite.scale;
				if (_recentScales.length == _trailLength)
				{
					spriteScale = _recentScales.pop();
				}
				else
				{
					spriteScale = new FlxPoint();
				}
				
				spriteScale.set(sprite.scale.x, sprite.scale.y);
				_recentScales.unshift(spriteScale);
			}
			
			// Again the same thing for Sprites frames if framesEnabled
			if (framesEnabled && _image == null) 
			{
				var spriteFrame:Int = sprite.animation.frameIndex;
				_recentFrames.unshift(spriteFrame);
				
				if (_recentFrames.length > _trailLength) 
				{
					_recentFrames.pop();
				}
				
				var spriteFacing:Int = sprite.facing;
				_recentFacings.unshift(spriteFacing);
				
				if (_recentFacings.length > _trailLength) 
				{
					_recentFacings.pop();
				}
			}

			// Now we need to update the all the Trailsprites' values
			var trailSprite:FlxSprite;
			
			for (i in 0..._recentPositions.length) 
			{
				trailSprite = members[i];
				trailSprite.x = _recentPositions[i].x;
				trailSprite.y = _recentPositions[i].y;
				
				// And the angle...
				if (rotationsEnabled) 
				{
					trailSprite.angle = _recentAngles[i];
					trailSprite.origin.x = _spriteOrigin.x;
					trailSprite.origin.y = _spriteOrigin.y;
				}
				
				// the scale...
				if (scalesEnabled) 
				{
					trailSprite.scale.x = _recentScales[i].x;
					trailSprite.scale.y = _recentScales[i].y;
				}
				
				// and frame...
				if (framesEnabled && _image == null) 
				{
					trailSprite.animation.frameIndex = _recentFrames[i];
					trailSprite.facing = _recentFacings[i];
				}

				// Is the trailsprite even visible?
				trailSprite.exists = true; 
			}
		}

		super.update();
	}

	public function resetTrail():Void
	{
		_recentPositions.splice(0, _recentPositions.length);
		_recentAngles.splice(0, _recentAngles.length);
		_recentScales.splice(0, _recentScales.length);
		_recentFrames.splice(0, _recentFrames.length);
		_recentFacings.splice(0, _recentFacings.length);
		
		for (i in 0...members.length) 
		{
			if (members[i] != null)
			{
				members[i].exists = false;
			}
		}
	}

	/**
	 * A function to add a specific number of sprites to the trail to increase its length.
	 *
	 * @param 	Amount	The amount of sprites to add to the trail.
	 */
	public function increaseLength(Amount:Int):Void
	{
		// Can't create less than 1 sprite obviously
		if (Amount <= 0) 
		{
			return;
		}

		_trailLength += Amount;

		// Create the trail sprites
		for (i in 0...Amount)
		{
			var trailSprite:FlxSprite = new FlxSprite(0, 0);
			
			
			if (_image == null) 
			{
				trailSprite.loadfromSprite(sprite);
			}
			else 
			{
				trailSprite.loadGraphic(_image);
			}
			trailSprite.exists = false;
			add(trailSprite);
			trailSprite.alpha = _transp;
			_transp -= _difference;
			trailSprite.solid = solid;
			
			if (trailSprite.alpha <= 0) 
			{
				trailSprite.kill();
			}
		}	
	}

	/**
	 * In case you want to change the trailsprite image in runtime...
	 *
	 * @param 	Image	The image the sprites should load
	 */
	public function changeGraphic(Image:Dynamic):Void
	{
		_image = Image;
		
		for (i in 0..._trailLength)
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
	 * @param	Scale	Wheater the trail reacts to scale changes or not.
	 */
	public function changeValuesEnabled(Angle:Bool, X:Bool = true, Y:Bool = true, Scale:Bool = true):Void
	{
		rotationsEnabled = Angle;
		xEnabled = X;
		yEnabled = Y;
		scalesEnabled = Scale;
	}
	
	/**
	 * Determines whether trailsprites are solid or not. False by default.
	 */
	public var solid(default, set):Bool = false;
	
	private function set_solid(Value:Bool):Bool
	{
		for (i in 0..._trailLength)
		{
			members[i].solid = Value; 
		}
		
		return solid = Value;
	}
}
