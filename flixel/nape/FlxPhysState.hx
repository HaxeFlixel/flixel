package flixel.nape;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.space.Space;
import flixel.FlxG;
import flixel.FlxState;

#if !FLX_NO_DEBUG
import nape.util.ShapeDebug;
#end

/**
 * <code>FlxPhysState</code> is an <code>FlxState</code> that integrates <code>nape.space.Space</code>
 * to provide Nape physics simulation in Flixel.
 *
 * Extend this state, add some <code>FlxPhysSprite(s)</code> to start using flixel + nape physics.
 *
 * Note that </code>space</code> is a static variable, use <code>FlxPhysState.space</code>
 * to access it.
 *
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */

class FlxPhysState extends FlxState
{
	/**
	 * The space where the nape physics simulation occur.
	 */
	static public var space:Space;
	/**
	 * The number of iterations used by nape in resolving
	 * errors in the velocities of objects. This is
	 * together with collision detection the most
	 * expensive phase of a simulation update, as well
	 * as the most important for stable results.
	 * (default 10)
	 */
	public var velocityIterations:Int = 10;
	/**
	 * The number of iterations used by nape in resolving
	 * errors in the positions of objects. This is
	 * far more lightweight than velocity iterations,
	 * is well as being less important for the
	 * stability of results. (default 10)
	 */
	public var positionIterations:Int = 10;
	
	#if !FLX_NO_DEBUG
	/**
	 * Contains the sprite used for nape debug graphics.
	 */
	private var _physDbgSpr:ShapeDebug;
	/**
	 * Contains the sprite used for nape debug graphics.
	 */
	static public var debug(get, never):ShapeDebug;
	
	static private function get_debug():ShapeDebug 
	{ 
		return cast(FlxG.state, FlxPhysState)._physDbgSpr; 
	}
	#end

	/**
	 * Override this method like a normal <code>FlxState</code>, but add
	 * <code>super.create()</code> to it, so that this function is called.
	 */
	override public function create():Void
	{
		if (space == null)
		{
			space = new Space(new Vec2());
		}
		
		#if !FLX_NO_DEBUG
		enablePhysDebug();
		#end
	}

	/**
	 * Creates simple walls around game area - usefull for prototying.
	 *
	 * @param 	MinX 		The smallest X value of your level (usually 0).
	 * @param 	MinY 		The smallest Y value of your level (usually 0).
	 * @param 	MaxX 		The largest X value of your level - 0 means <code>FlxG.width</code> (usually the level width).
	 * @param 	MaxY 		The largest Y value of your level - 0 means <code>FlxG.height</code> (usually the level height).
	 * @param 	Thickness 	How thick the walls are. 10 by default.
	 * @param 	_Material 	The <code>Material</code> to use for the physics body of the walls.
	 */
	public function createWalls(MinX:Float = 0, MinY:Float = 0, MaxX:Float = 0, MaxY:Float = 0, Thickness:Float = 10, _Material:Material = null):Body
	{
		if (MaxX == 0)
		{
			MaxX = FlxG.width;
		}
		
		if (MinY == 0)
		{
			MinY = FlxG.height;
		}
		
		if (_Material == null)
		{
			_Material = new Material(0.4, 0.2, 0.38, 0.7);
		}
		
		var walls:Body = new Body(BodyType.STATIC);
		
		// Left wall
		walls.shapes.add(new Polygon(Polygon.rect(MinX, MinY, Thickness, MaxY + Math.abs(MinY))));
		// Right wall
		walls.shapes.add(new Polygon(Polygon.rect(MaxX - Thickness, MinY, Thickness, MaxY + Math.abs(MinY))));
		// Upper wall
		walls.shapes.add(new Polygon(Polygon.rect(MinX, MinY, MaxX + Math.abs(MinX), Thickness)));
		// Bottom wall
		walls.shapes.add(new Polygon(Polygon.rect(MinX, MaxY - Thickness, MaxX + Math.abs(MinX), Thickness)));

		walls.space = space;
		walls.setShapeMaterials(_Material);
		
		return walls;
	}

	/**
	 * Override this method and add <code>super.update()</code>.
	 */
	override public function update():Void
	{
		space.step(FlxG.elapsed, velocityIterations, positionIterations);
		
		super.update();
	}

	/**
	 * Override this method to draw debug physics shapes
	 */
	override public function draw():Void
	{
		super.draw();
		
		#if !FLX_NO_DEBUG
		drawPhysDebug();
		#end
	}

	/**
	 * Override this function to null out variables or manually call
	 * <code>destroy()</code> on class members if necessary.
	 * Don't forget to call <code>super.destroy()</code>!
	 */
	override public function destroy():Void
	{
		super.destroy();
		
		space.clear();

		#if !FLX_NO_DEBUG
		disablePhysDebug();
		#end
	}

	/**
	 * Enables debug graphics for nape physics.
	 */
	public function enablePhysDebug():Void
	{
		#if !FLX_NO_DEBUG
		if (_physDbgSpr != null)
		{
			disablePhysDebug();
		}
		
		_physDbgSpr = new ShapeDebug(FlxG.width, FlxG.height);
		_physDbgSpr.drawConstraints = true;
		
		FlxG.stage.addChild(_physDbgSpr.display);
		#end
	}

	/**
	 * Disables debug graphics.
	 */
	public function disablePhysDebug():Void
	{
		#if !FLX_NO_DEBUG
		if (_physDbgSpr == null)
		{
			return;
		}

		FlxG.stage.removeChild(_physDbgSpr.display);
		_physDbgSpr = null;
		#end
	}

	/**
	 * Draws debug graphics.
	 */
	private function drawPhysDebug():Void
	{
		#if !FLX_NO_DEBUG
		if (_physDbgSpr == null || space == null)
		{
			return;
		}
		
		_physDbgSpr.clear();
		_physDbgSpr.draw(space);
		
		var cam = FlxG.camera;
		var zoom = cam.zoom;
		
		_physDbgSpr.display.scaleX = zoom;
		_physDbgSpr.display.scaleY = zoom;
		
		if (cam.target == null)
		{
			_physDbgSpr.display.x = cam.scroll.x * zoom;
			_physDbgSpr.display.y = cam.scroll.y * zoom;
		}
		else
		{
			_physDbgSpr.display.x = -cam.scroll.x * zoom;
			_physDbgSpr.display.y = -cam.scroll.y * zoom;
			_physDbgSpr.display.x += (FlxG.width - FlxG.width * zoom) / 2;
			_physDbgSpr.display.y += (FlxG.height - FlxG.height * zoom) / 2;
		}
		#end
	}
}