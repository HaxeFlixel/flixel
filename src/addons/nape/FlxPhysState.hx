package addons;
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
	private var _physDbgSpr:ShapeDebug;
	static public var space:Space;
	
	/**
	 * Override this method like a normal FlxState, but add
	 * <code>super.create()</code> to it, so that this function is called.
	 */
	override public function create():Void 
	{
		space = new Space(new Vec2());
		
		enablePhysDebug();
	}
	
	/**
	 * Override this method and add <code>super.update()</code>. 
	 */
	override public function update():Void 
	{
		
		space.step(FlxG.elapsed);
		if (_physDbgSpr != null) 
		{
			_physDbgSpr.clear();
			_physDbgSpr.draw(space);
			
			_physDbgSpr.display.scaleX = FlxG.camera.zoom; 
			_physDbgSpr.display.scaleY = FlxG.camera.zoom; 
			_physDbgSpr.display.x = -FlxG.camera.scroll.x * FlxG.camera.zoom;
			_physDbgSpr.display.y = -FlxG.camera.scroll.y * FlxG.camera.zoom;
			
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
	 */
	public function createWalls() 
	{
		var _thickness = 10;
		
		var wallLeft:Body 	= new Body(BodyType.STATIC);
		var wallRight:Body 	= new Body(BodyType.STATIC);
		var wallUp:Body 	= new Body(BodyType.STATIC);
		var wallDown:Body 	= new Body(BodyType.STATIC);
		
		wallLeft.setShapeMaterials(new Material(0.4, 0.2, 0.38, 0.7));
		wallDown.setShapeMaterials(new Material(0.4, 0.2, 0.38, 0.7));
		wallUp.setShapeMaterials(new Material(0.4, 0.2, 0.38, 0.7));
		wallRight.setShapeMaterials(new Material(0.4, 0.2, 0.38, 0.7));
		
		wallLeft.shapes.add(new Polygon(Polygon.rect(0,0,_thickness,FlxG.height)));
        wallRight.shapes.add(new Polygon(Polygon.rect(FlxG.width - _thickness,0,_thickness,FlxG.height)));
        wallUp.shapes.add(new Polygon(Polygon.rect(0,0,FlxG.width, _thickness)));
        wallDown.shapes.add(new Polygon(Polygon.rect(0, FlxG.height - _thickness, FlxG.width, _thickness)));
		
		wallLeft.space = space;
		wallRight.space = space;
		wallUp.space = space;
		wallDown.space = space;
	}
	
}