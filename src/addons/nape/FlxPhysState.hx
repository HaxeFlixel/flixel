package addons.nape;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.space.Space;
import nape.util.ShapeDebug;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxState;

/**
 * FlxPhysState is an FlxState that integrates nape.space.Space class 
 * to provide Nape physics simulation in Flixel.
 * 
 * Extend this state, add some FlxPhysSprite(s) to start using flixel + nape physics.
 * 
 * Note that 'space' is a static variable, use FlxPhysState.space
 * to access it.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */

class FlxPhysState extends FlxState
{
	/**
	 * Contains the sprite used for nape debug graphics.
	 */
	private var _physDbgSpr:ShapeDebug;
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
	public var velocityIterations:Int;
	/** 
	 * The number of iterations used by nape in resolving
     * errors in the positions of objects. This is
     * far more lightweight than velocity iterations,
     * is well as being less important for the
     * stability of results. (default 10)
	 */
	public var positionIterations:Int;
	
	/**
	 * Override this method like a normal FlxState, but add
	 * <code>super.create()</code> to it, so that this function is called.
	 */
	override public function create():Void 
	{
		space = new Space(new Vec2());
		velocityIterations = 10;	// Default value. 
		positionIterations = 10;	// Default value.
		
		enablePhysDebug();
	}
	
	/**
	 * Override this method and add <code>super.update()</code>. 
	 */
	override public function update():Void 
	{
		
		space.step(FlxG.elapsed, velocityIterations, positionIterations);
		if (_physDbgSpr != null) 
		{
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
			} else 
			{
				_physDbgSpr.display.x = -cam.scroll.x * zoom;
				_physDbgSpr.display.y = -cam.scroll.y * zoom;
				_physDbgSpr.display.x += (FlxG.width - FlxG.width * zoom) / 2; 
				_physDbgSpr.display.y += (FlxG.height - FlxG.height * zoom) / 2;
			}
			
		}
		
		super.update();
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
		disablePhysDebug();
	}
	
	/**
	 * Enables debug graphics for nape physics.
	 */
	public function enablePhysDebug() 
	{
		if (_physDbgSpr != null) 
		{
			disablePhysDebug();
		}
		
		_physDbgSpr = new ShapeDebug(FlxG.width, FlxG.height);
		_physDbgSpr.drawConstraints = true;
		
		FlxG.stage.addChild(_physDbgSpr.display);
		//FlxG.camera._flashSprite.addChild(_physDbgSpr.display);
		//_physDbgSpr.display.x = 100;
		//_physDbgSpr.display.y = 140;
	}
	
	/**
	 * Disables debug graphics.
	 */
	public function disablePhysDebug()
	{
		if (_physDbgSpr == null) 
		{
			return;
		}
		
		FlxG.stage.removeChild(_physDbgSpr.display);
		_physDbgSpr = null;
	}
	
	/**
	 * Creates simple walls around game area - usefull for prototying.
	 * 
	 * @param	minX	The smallest X value of your level (usually 0).
	 * @param	minY	The smallest Y value of your level (usually 0).
	 * @param	maxX	The largest X value of your level (usually the level width).
	 * @param	maxY	The largest Y value of your level (usually the level height).
	 * @param	Thickness	How thick the walls are.
	 */
	public function createWalls(minX:Float = 0, minY:Float = 0, MaxX:Float = 0, MaxY:Float = 0, Thickness:Float = 10, material:Material = null) 
	{
		
		if (MaxX == 0) 
			MaxX = FlxG.width;
			
		if (MaxY == 0)
			MaxY = FlxG.height;
			
		if (material == null)
			material = new Material(0.4, 0.2, 0.38, 0.7);
		
		var wallLeft:Body 	= new Body(BodyType.STATIC);
		var wallRight:Body 	= new Body(BodyType.STATIC);
		var wallUp:Body 	= new Body(BodyType.STATIC);
		var wallDown:Body 	= new Body(BodyType.STATIC);
		
		wallLeft.shapes.add(new Polygon(Polygon.rect(minX, minY, Thickness, MaxY + Math.abs(minY))));
        wallRight.shapes.add(new Polygon(Polygon.rect(MaxX - Thickness, minY, Thickness, MaxY + Math.abs(minY))));
        wallUp.shapes.add(new Polygon(Polygon.rect(minX, minY, MaxX + Math.abs(minX), Thickness)));
        wallDown.shapes.add(new Polygon(Polygon.rect(minX, MaxY - Thickness, MaxX + Math.abs(minX), Thickness)));
		
		wallLeft.space = space;
		wallRight.space = space;
		wallUp.space = space;
		wallDown.space = space;
		
		wallLeft.setShapeMaterials(material);
		wallRight.setShapeMaterials(material);
		wallUp.setShapeMaterials(material);
		wallDown.setShapeMaterials(material);
	}
	
}