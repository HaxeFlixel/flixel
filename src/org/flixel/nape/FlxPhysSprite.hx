package org.flixel.nape;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import org.flixel.FlxSprite;

/**
 * FlxPhysSprite consists of an FlxSprite with a physics body.
 * During the simulation, the sprite follows the physics body position and rotation.
 * 
 * Override createPhysObjects() method to create your own physics body (default one is a circle).
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class FlxPhysSprite extends FlxSprite
{
	private var _radsFactor:Float;
	private var _linearDrag:Float;
	private var _angularDrag:Float;
	
	/**
	 * mainBody is the physics body associated with this sprite. 
	 */
	public var mainBody:Body;

	/**
	 * Creates an FlxSprite and a physics body (<code>mainBody</code>).
	 * The body is then added to the space of the current state.
	 * At each step, the physics are updated, and so is the position and rotation of the sprite 
	 * to match the bodys position and rotation values.
	 * 
	 * @param	X				The initial X position of the sprite.
	 * @param	Y				The initial Y position of the sprite.
	 * @param	SimpleGraphic 	The graphic you want to display (OPTIONAL - for simple stuff only, do NOT use for animated images!).
	 */
	public function new(X:Float = 0, Y:Float = 0, SimpleGraphic:Dynamic = null) 
	{
		super(X, Y, SimpleGraphic);
		_radsFactor = 180 / 3.14159;
		_linearDrag = 1;	// no drag.
		_angularDrag = 1; 	// no drag.
		
		createRectangularBody();
	}

	/**
	 * Override this function to null out variables or manually call
	 * <code>destroy()</code> on class members if necessary.
	 * Don't forget to call <code>super.destroy()</code>!
	 */
	override public function destroy():Void 
	{
		destroyPhysObjects();
		super.destroy();
	}

	/**
	 * Override core physics velocity etc
	 */
	override public function postUpdate():Void
	{
		if (moves)
		{
			updatePhysObjects();
		}
	}

	/**
	 * Handy function for "killing" game objects.
	 * Default behavior is to flag them as nonexistent AND dead.
	 */
	override public function kill():Void
	{
		super.kill();
		mainBody.space = null;
	}

	/**
	 * Handy function for bringing game objects "back to life". Just sets alive and exists back to true.
	 * In practice, this function is most often called by <code>FlxObject.reset()</code>.
	 */
	override public function revive():Void
	{
		super.revive();
		mainBody.space = FlxPhysState.space;
	}
	
	/**
	 * Creates the physics body used by this sprite (using a circle shape).
	 */
	public function createCircularBody(radius:Float = 16) 
	{
		if (mainBody != null) 
			destroyPhysObjects();
			
		this.centerOffsets(false);
		mainBody = new Body(BodyType.DYNAMIC, new Vec2(this.x, this.y));
		mainBody.shapes.add(new Circle(radius));
		mainBody.space = FlxPhysState.space;
		
		setBodyMaterial();
	}
	
	/**
	 * Default method to create the physics body used by this sprite in shape of a rectangle.
	 * Override this method to create your own physics body!
	 * The width and height used are based on the size of sprite graphics.
	 * Call this method after calling makeGraphics() or loadGraphic() to update the body size.
	 */
	public function createRectangularBody()
	{
		if (mainBody != null) 
			destroyPhysObjects();
			
		this.centerOffsets(false);
		mainBody = new Body(BodyType.DYNAMIC, new Vec2(this.x, this.y));
		mainBody.shapes.add(new Polygon(Polygon.box(frameWidth, frameHeight)));
		mainBody.space = FlxPhysState.space;
		
		setBodyMaterial();
	}
	
	/**
	 * Shortcut method to set/change the physics body material.
	 * 
	 * @param	elasticity			Elasticity of material.		
	 * @param	dynamicFriction		Coeffecient of dynamic friction for material.
	 * @param	staticFriction		Coeffecient of static friction for material.
	 * @param	density				Density of this Material.
	 * @param	rotationFriction	Coeffecient of rolling friction for circle interactions.
	 */
	public function setBodyMaterial(elasticity:Float = 1, dynamicFriction:Float = 0.2, 
									staticFriction:Float = 0.4, density:Float = 1, 
									rollingFriction:Float = 0.001)
	{
		if (mainBody == null) 
			return;
		mainBody.setShapeMaterials(new Material(elasticity, dynamicFriction, staticFriction, density, rollingFriction));
	}
	
	/**
	 * Destroys the physics main body.
	 */
	public function destroyPhysObjects() 
	{
		if (mainBody != null) 
		{
			FlxPhysState.space.bodies.remove(mainBody);
			mainBody = null;
		}
	}
	
	/**
	 * Updates physics FlxSprite graphics to follow this sprite physics object.
	 */	
	private inline function updatePhysObjects() 
	{
		this.x = mainBody.position.x - origin.x;
		this.y = mainBody.position.y - origin.y;
		
		if (mainBody.allowRotation) 
		{
			this.angle = mainBody.rotation * _radsFactor;
		}
		
		// Applies custom physics drag.
		if (_linearDrag < 1 || _angularDrag < 1) 
		{
			mainBody.angularVel *= _angularDrag;
			mainBody.velocity.x *= _linearDrag;
			mainBody.velocity.y *= _linearDrag;
		}
	}

	/**
	 * Nape requires fluid spaces to add empty space linear drag and angular drag.
	 * This provides a simple drag alternative. 
	 * Set any values to linearDrag or angularDrag to activate this feature for this object.
	 * 
	 * @param	linearDrag Typical value 0.96
	 * @param	angularDrag	Typical value 0.96
	 */
	public function setDrag(linearDrag:Float, angularDrag:Float) 
	{
		_linearDrag		= linearDrag;
		_angularDrag 	= angularDrag;
	}
	
}
