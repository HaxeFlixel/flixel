package org.flixel;

import nme.display.Graphics;
import nme.display.Sprite;
import nme.geom.Point;

import org.flixel.FlxBasic;

/**
 * This is the base class for most of the display objects (<code>FlxSprite</code>, <code>FlxText</code>, etc).
 * It includes some basic attributes about game objects, including retro-style flickering,
 * basic state information, sizes, scrolling, and basic physics and motion.
 */

class FlxObject extends FlxBasic
{
	/**
	 * This value dictates the maximum number of pixels two objects have to intersect before collision stops trying to separate them.
	 * Don't modify this unless your objects are passing through eachother.
	 */
	static public var SEPARATE_BIAS:Float = 4;
	/**
	 * Generic value for "left" Used by <code>facing</code>, <code>allowCollisions</code>, and <code>touching</code>.
	 */
	static public inline var LEFT:Int	= 0x0001;
	/**
	 * Generic value for "right" Used by <code>facing</code>, <code>allowCollisions</code>, and <code>touching</code>.
	 */
	static public inline var RIGHT:Int	= 0x0010;
	/**
	 * Generic value for "up" Used by <code>facing</code>, <code>allowCollisions</code>, and <code>touching</code>.
	 */
	static public inline var UP:Int		= 0x0100;
	/**
	 * Generic value for "down" Used by <code>facing</code>, <code>allowCollisions</code>, and <code>touching</code>.
	 */
	static public inline var DOWN:Int	= 0x1000;
	/**
	 * Special-case constant meaning no collisions, used mainly by <code>allowCollisions</code> and <code>touching</code>.
	 */
	static public inline var NONE:Int	= 0;
	/**
	 * Special-case constant meaning up, used mainly by <code>allowCollisions</code> and <code>touching</code>.
	 */
	static public inline var CEILING:Int= UP;
	/**
	 * Special-case constant meaning down, used mainly by <code>allowCollisions</code> and <code>touching</code>.
	 */
	static public inline var FLOOR:Int	= DOWN;
	/**
	 * Special-case constant meaning only the left and right sides, used mainly by <code>allowCollisions</code> and <code>touching</code>.
	 */
	static public inline var WALL:Int	= LEFT | RIGHT;
	/**
	 * Special-case constant meaning any direction, used mainly by <code>allowCollisions</code> and <code>touching</code>.
	 */
	static public inline var ANY:Int	= LEFT | RIGHT | UP | DOWN;
	
	/**
	 * Path behavior controls: move from the start of the path to the end then stop.
	 */
	static public inline var PATH_FORWARD:Int			= 0x000000;
	/**
	 * Path behavior controls: move from the end of the path to the start then stop.
	 */
	static public inline var PATH_BACKWARD:Int			= 0x000001;
	/**
	 * Path behavior controls: move from the start of the path to the end then directly back to the start, and start over.
	 */
	static public inline var PATH_LOOP_FORWARD:Int		= 0x000010;
	/**
	 * Path behavior controls: move from the end of the path to the start then directly back to the end, and start over.
	 */
	static public inline var PATH_LOOP_BACKWARD:Int		= 0x000100;
	/**
	 * Path behavior controls: move from the start of the path to the end then turn around and go back to the start, over and over.
	 */
	static public inline var PATH_YOYO:Int				= 0x001000;
	/**
	 * Path behavior controls: ignores any vertical component to the path data, only follows side to side.
	 */
	static public inline var PATH_HORIZONTAL_ONLY:Int	= 0x010000;
	/**
	 * Path behavior controls: ignores any horizontal component to the path data, only follows up and down.
	 */
	static public inline var PATH_VERTICAL_ONLY:Int		= 0x100000;
	
	static private var _firstSeparateFlxRect:FlxRect = new FlxRect();
	static private var _secondSeparateFlxRect:FlxRect = new FlxRect();
	
	/**
	 * X position of the upper left corner of this object in world space.
	 */
	public var x:Float;
	/**
	 * Y position of the upper left corner of this object in world space.
	 */
	public var y:Float;
	/**
	 * The width of this object.
	 */
	public var width:Float;
	/**
	 * The height of this object.
	 */
	public var height:Float;

	/**
	 * Whether an object will move/alter position after a collision.
	 */
	public var immovable:Bool;
	
	/**
	 * The basic speed of this object.
	 */
	public var velocity:FlxPoint;
	/**
	 * The virtual mass of the object. Default value is 1.
	 * Currently only used with <code>elasticity</code> during collision resolution.
	 * Change at your own risk; effects seem crazy unpredictable so far!
	 */
	public var mass:Float;
	/**
	 * The bounciness of this object.  Only affects collisions.  Default value is 0, or "not bouncy at all."
	 */
	public var elasticity:Float;
	/**
	 * How fast the speed of this object is changing.
	 * Useful for smooth movement and gravity.
	 */
	public var acceleration:FlxPoint;
	/**
	 * This isn't drag exactly, more like deceleration that is only applied
	 * when acceleration is not affecting the sprite.
	 */
	public var drag:FlxPoint;
	/**
	 * If you are using <code>acceleration</code>, you can use <code>maxVelocity</code> with it
	 * to cap the speed automatically (very useful!).
	 */
	public var maxVelocity:FlxPoint;
	/**
	 * Set the angle of a sprite to rotate it.
	 * WARNING: rotating sprites decreases rendering
	 * performance for this sprite by a factor of 10x!
	 */
	public var angle:Float;
	/**
	 * This is how fast you want this sprite to spin.
	 */
	public var angularVelocity:Float;
	/**
	 * How fast the spin speed should change.
	 */
	public var angularAcceleration:Float;
	/**
	 * Like <code>drag</code> but for spinning.
	 */
	public var angularDrag:Float;
	/**
	 * Use in conjunction with <code>angularAcceleration</code> for fluid spin speed control.
	 */
	public var maxAngular:Float;
	/**
	 * Should always represent (0,0) - useful for different things, for avoiding unnecessary <code>new</code> calls.
	 */
	static private inline var _pZero:FlxPoint = new FlxPoint();
	
	/**
	 * A point that can store numbers from 0 to 1 (for X and Y independently)
	 * that governs how much this object is affected by the camera subsystem.
	 * 0 means it never moves, like a HUD element or far background graphic.
	 * 1 means it scrolls along a the same speed as the foreground layer.
	 * scrollFactor is initialized as (1,1) by default.
	 */
	public var scrollFactor:FlxPoint;
	/**
	 * Internal helper used for retro-style flickering.
	 */
	private var _flicker:Bool;
	/**
	 * Internal helper used for retro-style flickering.
	 */
	private var _flickerTimer:Float;
	/**
	 * Handy for storing health percentage or armor points or whatever.
	 */
	public var health:Float;
	/**
	 * This is just a pre-allocated x-y point container to be used however you like
	 */
	public var _point:FlxPoint;
	/**
	 * This is just a pre-allocated rectangle container to be used however you like
	 */
	public var _rect:FlxRect;
	/**
	 * Set this to false if you want to skip the automatic motion/movement stuff (see <code>updateMotion()</code>).
	 * FlxObject and FlxSprite default to true.
	 * FlxText, FlxTileblock and FlxTilemap default to false.
	 */
	public var moves:Bool;
	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating surface contacts.
	 * Use bitwise operators to check the values stored here, or use touching(), justStartedTouching(), etc.
	 * You can even use them broadly as boolean values if you're feeling saucy!
	 */
	public var touching:Int;
	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating surface contacts from the previous game loop step.
	 * Use bitwise operators to check the values stored here, or use touching(), justStartedTouching(), etc.
	 * You can even use them broadly as boolean values if you're feeling saucy!
	 */
	public var wasTouching:Int;
	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating collision directions.
	 * Use bitwise operators to check the values stored here.
	 * Useful for things like one-way platforms (e.g. allowCollisions = UP;)
	 * The accessor "solid" just flips this variable between NONE and ANY.
	 */
	public var allowCollisions:Int;
	/**
	 * Important variable for collision processing.
	 * By default this value is set automatically during <code>preUpdate()</code>.
	 */
	public var last:FlxPoint;
	
	/**
	 * A reference to a path object.  Null by default, assigned by <code>followPath()</code>.
	 */
	public var path:FlxPath;
	/**
	 * The speed at which the object is moving on the path.
	 * When an object completes a non-looping path circuit,
	 * the pathSpeed will be zeroed out, but the <code>path</code> reference
	 * will NOT be nulled out.  So <code>pathSpeed</code> is a good way
	 * to check if this object is currently following a path or not.
	 */
	public var pathSpeed:Float;
	/**
	 * The angle in degrees between this object and the next node, where 0 is directly upward, and 90 is to the right.
	 */
	public var pathAngle:Float;
	/**
	 * Internal helper, tracks which node of the path this object is moving toward.
	 */
	private var _pathNodeIndex:Int;
	/**
	 * Internal tracker for path behavior flags (like looping, horizontal only, etc).
	 */
	private var _pathMode:Int;
	/**
	 * Internal helper for node navigation, specifically yo-yo and backwards movement.
	 */
	private var _pathInc:Int;
	/**
	 * Internal flag for whether the object's angle should be adjusted to the path angle during path follow behavior.
	 */
	private var _pathRotate:Bool;
	
	#if !FLX_NO_DEBUG
	/**
	 * Overriding this will force a specific color to be used for debug rect.
	 */
	public var debugBoundingBoxColor(default, onBoundingBoxColorSet):Int;
	private var _boundingBoxColorOverritten:Bool = false;
	private function onBoundingBoxColorSet(val:Int):Int 
	{
		_boundingBoxColorOverritten = true;
		debugBoundingBoxColor = val;
		return val; 
	}
	#end
	
	/**
	 * Instantiates a <code>FlxObject</code>.
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 * @param	Width	Desired width of the rectangle.
	 * @param	Height	Desired height of the rectangle.
	 */
	public function new(X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0)
	{
		super();
		
		x = X;
		y = Y;
		last = new FlxPoint(x,y);
		width = Width;
		height = Height;
		mass = 1.0;
		elasticity = 0.0;
		
		health = 1;
		
		immovable = false;
		moves = true;
		
		touching = NONE;
		wasTouching = NONE;
		allowCollisions = ANY;
		
		velocity = new FlxPoint();
		acceleration = new FlxPoint();
		drag = new FlxPoint();
		maxVelocity = new FlxPoint(10000, 10000);
		
		angle = 0;
		angularVelocity = 0;
		angularAcceleration = 0;
		angularDrag = 0;
		maxAngular = 10000;
		
		scrollFactor = new FlxPoint(1.0, 1.0);
		_flicker = false;
		_flickerTimer = 0;
		
		_point = new FlxPoint();
		_rect = new FlxRect();
		
		path = null;
		pathSpeed = 0;
		pathAngle = 0;
	}
	
	/**
	 * Override this function to null out variables or
	 * manually call destroy() on class members if necessary.
	 * Don't forget to call super.destroy()!
	 */
	override public function destroy():Void
	{
		velocity = null;
		acceleration = null;
		drag = null;
		maxVelocity = null;
		scrollFactor = null;
		_point = null;
		_rect = null;
		last = null;
		cameras = null;
		if (path != null)
		{
			path.destroy();
		}
		path = null;
		super.destroy();
	}
	
	/**
	 * Pre-update is called right before <code>update()</code> on each object in the game loop.
	 * In <code>FlxObject</code> it controls the flicker timer,
	 * tracking the last coordinates for collision purposes,
	 * and checking if the object is moving along a path or not.
	 */
	override public function preUpdate():Void
	{
		FlxBasic._ACTIVECOUNT++;
		
		if(_flickerTimer > 0)
		{
			_flickerTimer -= FlxG.elapsed;
			if(_flickerTimer <= 0)
			{
				_flickerTimer = 0;
				_flicker = false;
			}
		}
		
		last.x = x;
		last.y = y;
		
		if ((path != null) && (pathSpeed != 0) && (path.nodes[_pathNodeIndex] != null))
		{
			updatePathMotion();
		}
	}
	
	/**
	 * Post-update is called right after <code>update()</code> on each object in the game loop.
	 * In <code>FlxObject</code> this function handles integrating the objects motion
	 * based on the velocity and acceleration settings, and tracking/clearing the <code>touching</code> flags.
	 */
	override public function postUpdate():Void
	{
		if (moves)
		{
			updateMotion();
		}
		
		wasTouching = touching;
		touching = NONE;
	}
	
	/**
	 * Internal function for updating the position and speed of this object.
	 * Useful for cases when you need to update this but are buried down in too many supers.
	 * Does a slightly fancier-than-normal integration to help with higher fidelity framerate-independenct motion.
	 */
	inline private function updateMotion():Void
	{
		var delta:Float;
		var velocityDelta:Float;
		
		var dt:Float = FlxG.elapsed;

		velocityDelta = 0.5 * (FlxU.computeVelocity(angularVelocity, angularAcceleration, angularDrag, maxAngular) - angularVelocity);
		angularVelocity += velocityDelta; 
		angle += angularVelocity * dt;
		angularVelocity += velocityDelta;
		
		velocityDelta = 0.5 * (FlxU.computeVelocity(velocity.x, acceleration.x, drag.x, maxVelocity.x) - velocity.x);
		velocity.x += velocityDelta;
		delta = velocity.x * dt;
		velocity.x += velocityDelta;
		x += delta;
		
		velocityDelta = 0.5 * (FlxU.computeVelocity(velocity.y, acceleration.y, drag.y, maxVelocity.y) - velocity.y);
		velocity.y += velocityDelta;
		delta = velocity.y * dt;
		velocity.y += velocityDelta;
		y += delta;
	}
	
	/**
	 * Rarely called, and in this case just increments the visible objects count and calls <code>drawDebug()</code> if necessary.
	 */
	override public function draw():Void
	{
		if (cameras == null)
		{
			cameras = FlxG.cameras;
		}
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		while (i < l)
		{
			camera = cameras[i++];
			if (!onScreenObject(camera) || !camera.visible || !camera.exists)
			{
				continue;
			}
			FlxBasic._VISIBLECOUNT++;
			
			#if !FLX_NO_DEBUG
			if (FlxG.visualDebug && !ignoreDrawDebug)
			{
				drawDebug(camera);
			}
			#end
			
		}
	}
	
	#if !FLX_NO_DEBUG
	/**
	 * Override this function to draw custom "debug mode" graphics to the
	 * specified camera while the debugger's visual mode is toggled on.
	 * 
	 * @param	Camera	Which camera to draw the debug visuals to.
	 */
	override public function drawDebug(Camera:FlxCamera = null):Void
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}

		//get bounding box coordinates
		var boundingBoxX:Float = x - (Camera.scroll.x * scrollFactor.x); //copied from getScreenXY()
		var boundingBoxY:Float = y - (Camera.scroll.y * scrollFactor.y);
		#if flash
		var boundingBoxWidth:Int = Std.int(width);
		var boundingBoxHeight:Int = Std.int(height);
		#end
		
		if (allowCollisions != FlxObject.NONE && !_boundingBoxColorOverritten)
		{
			if (allowCollisions != ANY)
			{
				#if !neko
				debugBoundingBoxColor = FlxG.PINK;
				#else
				debugBoundingBoxColor = FlxG.PINK.rgb;
				#end
			}
			if (immovable)
			{
				#if !neko
				debugBoundingBoxColor = FlxG.GREEN;
				#else
				debugBoundingBoxColor = FlxG.GREEN.rgb;
				#end
			}
			else
			{
				#if !neko
				debugBoundingBoxColor = FlxG.RED;
				#else
				debugBoundingBoxColor = FlxG.RED.rgb;
				#end
			}
		}
		else if (!_boundingBoxColorOverritten)
		{
			#if !neko
			debugBoundingBoxColor = FlxG.BLUE;
			#else
			debugBoundingBoxColor = FlxG.BLUE.rgb;
			#end
		}
		
		//fill static graphics object with square shape
		#if flash
		var gfx:Graphics = FlxG.flashGfx;
		gfx.clear();
		gfx.moveTo(boundingBoxX, boundingBoxY);
		gfx.lineStyle(1, debugBoundingBoxColor, 0.5);
		gfx.lineTo(boundingBoxX + boundingBoxWidth, boundingBoxY);
		gfx.lineTo(boundingBoxX + boundingBoxWidth, boundingBoxY + boundingBoxHeight);
		gfx.lineTo(boundingBoxX, boundingBoxY + boundingBoxHeight);
		gfx.lineTo(boundingBoxX, boundingBoxY);
		//draw graphics shape to camera buffer
		Camera.buffer.draw(FlxG.flashGfxSprite);
		#else
		var gfx:Graphics = Camera._effectsLayer.graphics;
		gfx.lineStyle(1, debugBoundingBoxColor, 0.5);
		gfx.drawRect(boundingBoxX, boundingBoxY, width, height);
		#end
	}
	#end
	
	/**
	 * Call this function to give this object a path to follow.
	 * If the path does not have at least one node in it, this function
	 * will log a warning message and return.
	 * @param	Path		The <code>FlxPath</code> you want this object to follow.
	 * @param	Speed		How fast to travel along the path in pixels per second.
	 * @param	Mode		Optional, controls the behavior of the object following the path using the path behavior constants.  Can use multiple flags at once, for example PATH_YOYO|PATH_HORIZONTAL_ONLY will make an object move back and forth along the X axis of the path only.
	 * @param	AutoRotate	Automatically point the object toward the next node.  Assumes the graphic is pointing upward.  Default behavior is false, or no automatic rotation.
	 */
	public function followPath(Path:FlxPath, Speed:Float = 100, Mode:Int = 0x000000, AutoRotate:Bool = false):Void
	{
		if(Path.nodes.length <= 0)
		{
			FlxG.log("WARNING: Paths need at least one node in them to be followed.");
			return;
		}
		
		path = Path;
		pathSpeed = FlxU.abs(Speed);
		_pathMode = Mode;
		_pathRotate = AutoRotate;
		
		//get starting node
		if((_pathMode == PATH_BACKWARD) || (_pathMode == PATH_LOOP_BACKWARD))
		{
			_pathNodeIndex = path.nodes.length - 1;
			_pathInc = -1;
		}
		else
		{
			_pathNodeIndex = 0;
			_pathInc = 1;
		}
	}
	
	/**
	 * Tells this object to stop following the path its on.
	 * @param	DestroyPath		Tells this function whether to call destroy on the path object.  Default value is false.
	 */
	public function stopFollowingPath(DestroyPath:Bool = false):Void
	{
		pathSpeed = 0;
		velocity.x = 0;
		velocity.y = 0;
		
		if(DestroyPath && (path != null))
		{
			path.destroy();
			path = null;
		}
	}
	
	/**
	 * Internal function that decides what node in the path to aim for next based on the behavior flags.
	 * @return	The node (a <code>FlxPoint</code> object) we are aiming for next.
	 */
	private function advancePath(Snap:Bool = true):FlxPoint
	{
		if (Snap)
		{
			var oldNode:FlxPoint = path.nodes[_pathNodeIndex];
			if (oldNode != null)
			{
				if ((_pathMode & PATH_VERTICAL_ONLY) == 0)
				{
					x = oldNode.x - width * 0.5;
				}
				if ((_pathMode & PATH_HORIZONTAL_ONLY) == 0)
				{
					y = oldNode.y - height * 0.5;
				}
			}
		}
		
		_pathNodeIndex += _pathInc;
		
		if ((_pathMode & PATH_BACKWARD) > 0)
		{
			if (_pathNodeIndex < 0)
			{
				_pathNodeIndex = 0;
				stopFollowingPath(false);
			}
		}
		else if ((_pathMode & PATH_LOOP_FORWARD) > 0)
		{
			if (_pathNodeIndex >= path.nodes.length)
			{
				_pathNodeIndex = 0;
			}
		}
		else if ((_pathMode & PATH_LOOP_BACKWARD) > 0)
		{
			if (_pathNodeIndex < 0)
			{
				_pathNodeIndex = path.nodes.length - 1;
				if (_pathNodeIndex < 0)
				{
					_pathNodeIndex = 0;
				}
			}
		}
		else if ((_pathMode & PATH_YOYO) > 0)
		{
			if (_pathInc > 0)
			{
				if (_pathNodeIndex >= path.nodes.length)
				{
					_pathNodeIndex = path.nodes.length - 2;
					if (_pathNodeIndex < 0)
					{
						_pathNodeIndex = 0;
					}
					_pathInc = -_pathInc;
				}
			}
			else if (_pathNodeIndex < 0)
			{
				_pathNodeIndex = 1;
				if (_pathNodeIndex >= path.nodes.length)
				{
					_pathNodeIndex = path.nodes.length - 1;
				}
				if (_pathNodeIndex < 0)
				{
					_pathNodeIndex = 0;
				}
				_pathInc = -_pathInc;
			}
		}
		else
		{
			if (_pathNodeIndex >= path.nodes.length)
			{
				_pathNodeIndex = path.nodes.length - 1;
				stopFollowingPath(false);
			}
		}

		return path.nodes[_pathNodeIndex];
	}
	
	/**
	 * Internal function for moving the object along the path.
	 * Generally this function is called automatically by <code>preUpdate()</code>.
	 * The first half of the function decides if the object can advance to the next node in the path,
	 * while the second half handles actually picking a velocity toward the next node.
	 */
	inline private function updatePathMotion():Void
	{
		//first check if we need to be pointing at the next node yet
		_point.x = x + width * 0.5;
		_point.y = y + height * 0.5;
		var node:FlxPoint = path.nodes[_pathNodeIndex];
		var deltaX:Float = node.x - _point.x;
		var deltaY:Float = node.y - _point.y;
		
		var horizontalOnly:Bool = (_pathMode & PATH_HORIZONTAL_ONLY) > 0;
		var verticalOnly:Bool = (_pathMode & PATH_VERTICAL_ONLY) > 0;
		
		if (horizontalOnly)
		{
			if (((deltaX > 0) ? deltaX : -deltaX) < pathSpeed * FlxG.elapsed)
			{
				node = advancePath();
			}
		}
		else if(verticalOnly)
		{
			if (((deltaY > 0) ? deltaY : -deltaY) < pathSpeed * FlxG.elapsed)
			{
				node = advancePath();
			}
		}
		else
		{
			if (Math.sqrt(deltaX * deltaX + deltaY * deltaY) < pathSpeed * FlxG.elapsed)
			{
				node = advancePath();
			}
		}
		
		//then just move toward the current node at the requested speed
		if(pathSpeed != 0)
		{
			//set velocity based on path mode
			_point.x = x + width * 0.5;
			_point.y = y + height * 0.5;
			if (horizontalOnly || (_point.y == node.y))
			{
				velocity.x = (_point.x < node.x) ? pathSpeed : -pathSpeed;
				if (velocity.x < 0)
				{
					pathAngle = -90;
				}
				else
				{
					pathAngle = 90;
				}
				if (!horizontalOnly)
				{
					velocity.y = 0;
				}
			}
			else if (verticalOnly || (_point.x == node.x))
			{
				velocity.y = (_point.y < node.y) ? pathSpeed : -pathSpeed;
				if (velocity.y < 0)
				{
					pathAngle = 0;
				}
				else
				{
					pathAngle = 180;
				}
				if (!verticalOnly)
				{
					velocity.x = 0;
				}
			}
			else
			{
				pathAngle = FlxU.getAngle(_point, node);
				FlxU.rotatePoint(0, pathSpeed, 0, 0, pathAngle, velocity);
			}
			
			//then set object rotation if necessary
			if (_pathRotate)
			{
				angularVelocity = 0;
				angularAcceleration = 0;
				angle = pathAngle;
			}
		}			
	}
	
	/**
	 * Checks to see if some <code>FlxObject</code> overlaps this <code>FlxObject</code> or <code>FlxGroup</code>.
	 * If the group has a LOT of things in it, it might be faster to use <code>FlxG.overlaps()</code>.
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 * @param	ObjectOrGroup	The object or group being tested.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.  Default is false, or "only compare in world space."
	 * @param	Camera			Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the two objects overlap.
	 */
	public function overlaps(ObjectOrGroup:FlxBasic, InScreenSpace:Bool = false, Camera:FlxCamera = null):Bool
	{
		if(Std.is(ObjectOrGroup, FlxTypedGroup))
		{
			var results:Bool = false;
			var i:Int = 0;
			var basic:FlxBasic;
			var grp:FlxTypedGroup<FlxBasic> = cast ObjectOrGroup;
			var members:Array<FlxBasic> = grp.members;
			while (i < grp.length)
			{
				basic = members[i++];
				if (basic != null && basic.exists && overlaps(basic, InScreenSpace, Camera))
				{
					results = true;
				}
			}
			return results;
		}
		
		if(Std.is(ObjectOrGroup, FlxTilemap))
		{
			//Since tilemap's have to be the caller, not the target, to do proper tile-based collisions,
			// we redirect the call to the tilemap overlap here.
			return cast(ObjectOrGroup, FlxTilemap).overlaps(this, InScreenSpace, Camera);
		}
		
		var object:FlxObject = cast(ObjectOrGroup, FlxObject);
		if(!InScreenSpace)
		{
			return	(object.x + object.width > x) && (object.x < x + width) &&
					(object.y + object.height > y) && (object.y < y + height);
		}

		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var objectScreenPos:FlxPoint = object.getScreenXY(null, Camera);
		getScreenXY(_point, Camera);
		return	(objectScreenPos.x + object.width > _point.x) && (objectScreenPos.x < _point.x + width) &&
				(objectScreenPos.y + object.height > _point.y) && (objectScreenPos.y < _point.y + height);
	}
	
	/**
	 * Checks to see if this <code>FlxObject</code> were located at the given position, would it overlap the <code>FlxObject</code> or <code>FlxGroup</code>?
	 * This is distinct from overlapsPoint(), which just checks that point, rather than taking the object's size into account.
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 * @param	X				The X position you want to check.  Pretends this object (the caller, not the parameter) is located here.
	 * @param	Y				The Y position you want to check.  Pretends this object (the caller, not the parameter) is located here.
	 * @param	ObjectOrGroup	The object or group being tested.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.  Default is false, or "only compare in world space."
	 * @param	Camera			Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the two objects overlap.
	 */
	public function overlapsAt(X:Float, Y:Float, ObjectOrGroup:FlxBasic, InScreenSpace:Bool = false, Camera:FlxCamera = null):Bool
	{
		if(Std.is(ObjectOrGroup, FlxTypedGroup))
		{
			var results:Bool = false;
			var basic:FlxBasic;
			var i:Int = 0;
			var grp:FlxTypedGroup<FlxBasic> = cast ObjectOrGroup;
			var members:Array<FlxBasic> = grp.members;
			while(i < Std.int(grp.length))
			{
				basic = members[i++];
				if (basic != null && basic.exists && overlapsAt(X, Y, basic, InScreenSpace, Camera))
				{
					results = true;
				}
			}
			return results;
		}
		
		if(Std.is(ObjectOrGroup, FlxTilemap))
		{
			//Since tilemap's have to be the caller, not the target, to do proper tile-based collisions,
			// we redirect the call to the tilemap overlap here.
			//However, since this is overlapsAt(), we also have to invent the appropriate position for the tilemap.
			//So we calculate the offset between the player and the requested position, and subtract that from the tilemap.
			var tilemap:FlxTilemap = cast(ObjectOrGroup, FlxTilemap);
			return tilemap.overlapsAt(tilemap.x - (X - x), tilemap.y - (Y - y), this, InScreenSpace, Camera);
		}
		
		var object:FlxObject = cast(ObjectOrGroup, FlxObject);
		if(!InScreenSpace)
		{
			return	(object.x + object.width > X) && (object.x < X + width) &&
					(object.y + object.height > Y) && (object.y < Y + height);
		}
		
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var objectScreenPos:FlxPoint = object.getScreenXY(null, Camera);
		_point.x = X - (Camera.scroll.x * scrollFactor.x); //copied from getScreenXY()
		_point.y = Y - (Camera.scroll.y * scrollFactor.y);
		return	(objectScreenPos.x + object.width > _point.x) && (objectScreenPos.x < _point.x + width) &&
			(objectScreenPos.y + object.height > _point.y) && (objectScreenPos.y < _point.y + height);
	}
	
	/**
	 * Checks to see if a point in 2D world space overlaps this <code>FlxObject</code> object.
	 * @param	Point			The point in world space you want to check.
	 * @param	InScreenSpace	Whether to take scroll factors into account when checking for overlap.
	 * @param	Camera			Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the point overlaps this object.
	 */
	public function overlapsPoint(point:FlxPoint, InScreenSpace:Bool = false, Camera:FlxCamera = null):Bool
	{
		if (!InScreenSpace)
		{
			return (point.x > x) && (point.x < x + width) && (point.y > y) && (point.y < y + height);
		}

		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var X:Float = point.x - Camera.scroll.x;
		var Y:Float = point.y - Camera.scroll.y;
		getScreenXY(_point, Camera);
		return (X > _point.x) && (X < _point.x + width) && (Y > _point.y) && (Y < _point.y + height);
	}
	
	/**
	 * Check and see if this object is currently on screen.
	 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether the object is on screen or not.
	 */
	public function onScreen(Camera:FlxCamera = null):Bool
	{
		return onScreenObject(Camera);
	}
	
	inline private function onScreenObject(Camera:FlxCamera = null):Bool
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		getScreenXY(_point,Camera);
		return (_point.x + width > 0) && (_point.x < Camera.width) && (_point.y + height > 0) && (_point.y < Camera.height);
	}
	
	/**
	 * Call this function to figure out the on-screen position of the object.
	 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @param	Point		Takes a <code>FlxPoint</code> object and assigns the post-scrolled X and Y values of this object to it.
	 * @return	The <code>Point</code> you passed in, or a new <code>Point</code> if you didn't pass one, containing the screen X and Y position of this object.
	 */
	inline public function getScreenXY(point:FlxPoint = null, Camera:FlxCamera = null):FlxPoint
	{
		if (point == null)
		{
			point = new FlxPoint();
		}
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		point.x = x - (Camera.scroll.x * scrollFactor.x);
		point.y = y - (Camera.scroll.y * scrollFactor.y);
		return point;
	}
	
	/**
	 * Tells this object to flicker, retro-style.
	 * Pass a negative value to flicker forever.
	 * @param	Duration	How many seconds to flicker for.
	 */
	public function flicker(Duration:Float = 1):Void
	{
		_flickerTimer = Duration;
		if (_flickerTimer == 0)
		{
			_flicker = false;
		}
	}
	
	/**
	 * Check to see if the object is still flickering.
	 * @return	Whether the object is flickering or not.
	 */
	public var flickering(get_flickering, null):Bool;
	
	private function get_flickering():Bool
	{
		return _flickerTimer != 0;
	}
	
	public var solid(get_solid, set_solid):Bool;
	
	/**
	 * Whether the object collides or not.  For more control over what directions
	 * the object will collide from, use collision constants (like LEFT, FLOOR, etc)
	 * to set the value of allowCollisions directly.
	 */
	private function get_solid():Bool
	{
		return (allowCollisions & ANY) > NONE;
	}
	
	/**
	 * @private
	 */
	private function set_solid(Solid:Bool):Bool
	{
		if (Solid)
		{
			allowCollisions = ANY;
		}
		else
		{
			allowCollisions = NONE;
		}
		return Solid;
	}
	
	/**
	 * Retrieve the midpoint of this object in world coordinates.
	 * @Point	Allows you to pass in an existing <code>FlxPoint</code> object if you're so inclined.  Otherwise a new one is created.
	 * @return	A <code>FlxPoint</code> object containing the midpoint of this object in world coordinates.
	 */
	inline public function getMidpoint(point:FlxPoint = null):FlxPoint
	{
		if (point == null)
		{
			point = new FlxPoint();
		}
		point.x = x + width * 0.5;
		point.y = y + height * 0.5;
		return point;
	}
	
	/**
	 * Handy function for reviving game objects.
	 * Resets their existence flags and position.
	 * @param	X	The new X position of this object.
	 * @param	Y	The new Y position of this object.
	 */
	public function reset(X:Float, Y:Float):Void
	{
		revive();
		touching = NONE;
		wasTouching = NONE;
		x = X;
		y = Y;
		last.x = x;
		last.y = y;
		velocity.x = 0;
		velocity.y = 0;
	}
	
	/**
	 * Handy function for checking if this object is touching a particular surface.
	 * @param	Direction	Any of the collision flags (e.g. LEFT, FLOOR, etc).
	 * @return	Whether the object is touching an object in (any of) the specified direction(s) this frame.
	 */
	inline public function isTouching(Direction:Int):Bool
	{
		return (touching & Direction) > NONE;
	}
	
	/**
	 * Handy function for checking if this object is just landed on a particular surface.
	 * @param	Direction	Any of the collision flags (e.g. LEFT, FLOOR, etc).
	 * @return	Whether the object just landed on (any of) the specified surface(s) this frame.
	 */
	inline public function justTouched(Direction:Int):Bool
	{
		return ((touching & Direction) > NONE) && ((wasTouching & Direction) <= NONE);
	}
	
	/**
	 * Reduces the "health" variable of this sprite by the amount specified in Damage.
	 * Calls kill() if health drops to or below zero.
	 * @param	Damage		How much health to take away (use a negative number to give a health bonus).
	 */
	public function hurt(Damage:Float):Void
	{
		health = health - Damage;
		if (health <= 0)
		{
			kill();
		}
	}
	
	/**
	 * The main collision resolution function in flixel.
	 * @param	Object1 	Any <code>FlxObject</code>.
	 * @param	Object2		Any other <code>FlxObject</code>.
	 * @return	Whether the objects in fact touched and were separated.
	 */
	inline static public function separate(Object1:FlxObject, Object2:FlxObject):Bool
	{
		var separatedX:Bool = separateX(Object1, Object2);
		var separatedY:Bool = separateY(Object1, Object2);
		return separatedX || separatedY;
	}
	
	/**
	 * The X-axis component of the object separation process.
	 * @param	Object1 	Any <code>FlxObject</code>.
	 * @param	Object2		Any other <code>FlxObject</code>.
	 * @return	Whether the objects in fact touched and were separated along the X axis.
	 */
	static public function separateX(Object1:FlxObject, Object2:FlxObject):Bool
	{
		//can't separate two immovable objects
		var obj1immovable:Bool = Object1.immovable;
		var obj2immovable:Bool = Object2.immovable;
		if (obj1immovable && obj2immovable)
		{
			return false;
		}
		
		//If one of the objects is a tilemap, just pass it off.
		if (Std.is(Object1, FlxTilemap))
		{
			return cast(Object1, FlxTilemap).overlapsWithCallback(Object2, separateX);
		}
		if (Std.is(Object2, FlxTilemap))
		{
			return cast(Object2, FlxTilemap).overlapsWithCallback(Object1, separateX, true);
		}
		
		//First, get the two object deltas
		var overlap:Float = 0;
		var obj1delta:Float = Object1.x - Object1.last.x;
		var obj2delta:Float = Object2.x - Object2.last.x;
		if(obj1delta != obj2delta)
		{
			//Check if the X hulls actually overlap
			var obj1deltaAbs:Float = (obj1delta > 0)?obj1delta: -obj1delta;
			var obj2deltaAbs:Float = (obj2delta > 0)?obj2delta: -obj2delta;
			
			var obj1rect:FlxRect = _firstSeparateFlxRect.make(Object1.x - ((obj1delta > 0)?obj1delta:0), Object1.last.y, Object1.width + ((obj1delta > 0)?obj1delta: -obj1delta), Object1.height);
			var obj2rect:FlxRect = _secondSeparateFlxRect.make(Object2.x - ((obj2delta > 0)?obj2delta:0), Object2.last.y, Object2.width + ((obj2delta > 0)?obj2delta: -obj2delta), Object2.height);
			
			if((obj1rect.x + obj1rect.width > obj2rect.x) && (obj1rect.x < obj2rect.x + obj2rect.width) && (obj1rect.y + obj1rect.height > obj2rect.y) && (obj1rect.y < obj2rect.y + obj2rect.height))
			{
				var maxOverlap:Float = obj1deltaAbs + obj2deltaAbs + SEPARATE_BIAS;
				
				//If they did overlap (and can), figure out by how much and flip the corresponding flags
				if(obj1delta > obj2delta)
				{
					overlap = Object1.x + Object1.width - Object2.x;
					if ((overlap > maxOverlap) || ((Object1.allowCollisions & RIGHT) == 0) || ((Object2.allowCollisions & LEFT) == 0))
					{
						overlap = 0;
					}
					else
					{
						Object1.touching |= RIGHT;
						Object2.touching |= LEFT;
					}
				}
				else if(obj1delta < obj2delta)
				{
					overlap = Object1.x - Object2.width - Object2.x;
					if((-overlap > maxOverlap) || ((Object1.allowCollisions & LEFT) == 0) || ((Object2.allowCollisions & RIGHT) == 0))
					{
						overlap = 0;
					}
					else
					{
						Object1.touching |= LEFT;
						Object2.touching |= RIGHT;
					}
				}
			}
		}
		
		//Then adjust their positions and velocities accordingly (if there was any overlap)
		if(overlap != 0)
		{
			var obj1v:Float = Object1.velocity.x;
			var obj2v:Float = Object2.velocity.x;
			
			if(!obj1immovable && !obj2immovable)
			{
				overlap *= 0.5;
				Object1.x = Object1.x - overlap;
				Object2.x += overlap;

				var obj1velocity:Float = Math.sqrt((obj2v * obj2v * Object2.mass) / Object1.mass) * ((obj2v > 0)?1: -1);
				var obj2velocity:Float = Math.sqrt((obj1v * obj1v * Object1.mass) / Object2.mass) * ((obj1v > 0)?1: -1);
				var average:Float = (obj1velocity + obj2velocity) * 0.5;
				obj1velocity -= average;
				obj2velocity -= average;
				Object1.velocity.x = average + obj1velocity * Object1.elasticity;
				Object2.velocity.x = average + obj2velocity * Object2.elasticity;
			}
			else if(!obj1immovable)
			{
				Object1.x = Object1.x - overlap;
				Object1.velocity.x = obj2v - obj1v * Object1.elasticity;
			}
			else if(!obj2immovable)
			{
				Object2.x += overlap;
				Object2.velocity.x = obj1v - obj2v * Object2.elasticity;
			}
			return true;
		}
		else
		{
			return false;
		}
	}
	
	/**
	 * The Y-axis component of the object separation process.
	 * @param	Object1 	Any <code>FlxObject</code>.
	 * @param	Object2		Any other <code>FlxObject</code>.
	 * @return	Whether the objects in fact touched and were separated along the Y axis.
	 */
	static public function separateY(Object1:FlxObject, Object2:FlxObject):Bool
	{
		//can't separate two immovable objects
		var obj1immovable:Bool = Object1.immovable;
		var obj2immovable:Bool = Object2.immovable;
		if (obj1immovable && obj2immovable)
		{
			return false;
		}
		
		//If one of the objects is a tilemap, just pass it off.
		if (Std.is(Object1, FlxTilemap))
		{
			return cast(Object1, FlxTilemap).overlapsWithCallback(Object2, separateY);
		}
		if (Std.is(Object2, FlxTilemap))
		{
			return cast(Object2, FlxTilemap).overlapsWithCallback(Object1, separateY, true);
		}

		//First, get the two object deltas
		var overlap:Float = 0;
		var obj1delta:Float = Object1.y - Object1.last.y;
		var obj2delta:Float = Object2.y - Object2.last.y;
		if(obj1delta != obj2delta)
		{
			//Check if the Y hulls actually overlap
			var obj1deltaAbs:Float = (obj1delta > 0)?obj1delta: -obj1delta;
			var obj2deltaAbs:Float = (obj2delta > 0)?obj2delta: -obj2delta;
			
			var obj1rect:FlxRect = _firstSeparateFlxRect.make(Object1.x, Object1.y - ((obj1delta > 0)?obj1delta:0), Object1.width, Object1.height + obj1deltaAbs);
			var obj2rect:FlxRect = _secondSeparateFlxRect.make(Object2.x, Object2.y - ((obj2delta > 0)?obj2delta:0), Object2.width, Object2.height + obj2deltaAbs);
			
			if((obj1rect.x + obj1rect.width > obj2rect.x) && (obj1rect.x < obj2rect.x + obj2rect.width) && (obj1rect.y + obj1rect.height > obj2rect.y) && (obj1rect.y < obj2rect.y + obj2rect.height))
			{
				var maxOverlap:Float = obj1deltaAbs + obj2deltaAbs + SEPARATE_BIAS;
				
				//If they did overlap (and can), figure out by how much and flip the corresponding flags
				if(obj1delta > obj2delta)
				{
					overlap = Object1.y + Object1.height - Object2.y;
					if ((overlap > maxOverlap) || ((Object1.allowCollisions & DOWN) == 0) || ((Object2.allowCollisions & UP) == 0))
					{
						overlap = 0;
					}
					else
					{
						Object1.touching |= DOWN;
						Object2.touching |= UP;
					}
				}
				else if(obj1delta < obj2delta)
				{
					overlap = Object1.y - Object2.height - Object2.y;
					if ((-overlap > maxOverlap) || ((Object1.allowCollisions & UP) == 0) || ((Object2.allowCollisions & DOWN) == 0))
					{
						overlap = 0;
					}
					else
					{
						Object1.touching |= UP;
						Object2.touching |= DOWN;
					}
				}
			}
		}
		
		//Then adjust their positions and velocities accordingly (if there was any overlap)
		if(overlap != 0)
		{
			var obj1v:Float = Object1.velocity.y;
			var obj2v:Float = Object2.velocity.y;
			
			if(!obj1immovable && !obj2immovable)
			{
				overlap *= 0.5;
				Object1.y = Object1.y - overlap;
				Object2.y += overlap;

				var obj1velocity:Float = Math.sqrt((obj2v * obj2v * Object2.mass)/Object1.mass) * ((obj2v > 0)?1:-1);
				var obj2velocity:Float = Math.sqrt((obj1v * obj1v * Object1.mass)/Object2.mass) * ((obj1v > 0)?1:-1);
				var average:Float = (obj1velocity + obj2velocity) * 0.5;
				obj1velocity -= average;
				obj2velocity -= average;
				Object1.velocity.y = average + obj1velocity * Object1.elasticity;
				Object2.velocity.y = average + obj2velocity * Object2.elasticity;
			}
			else if(!obj1immovable)
			{
				Object1.y = Object1.y - overlap;
				Object1.velocity.y = obj2v - obj1v*Object1.elasticity;
				//This is special case code that handles cases like horizontal moving platforms you can ride
				if (Object2.active && Object2.moves && (obj1delta > obj2delta))
				{
					Object1.x += Object2.x - Object2.last.x;
				}
			}
			else if(!obj2immovable)
			{
				Object2.y += overlap;
				Object2.velocity.y = obj1v - obj2v*Object2.elasticity;
				//This is special case code that handles cases like horizontal moving platforms you can ride
				if (Object1.active && Object1.moves && (obj1delta < obj2delta))
				{
					Object2.x += Object1.x - Object1.last.x;
				}
			}
			return true;
		}
		else
		{
			return false;
		}
	}
}