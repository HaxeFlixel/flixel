package flixel.effects;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.util.FlxAngle;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * This provides an area in which the added sprites have a trail effect
 * Usage: Create the FlxTrailArea and add it to the display.
 * Then add all sprites that should have a trail effect via the add function.
 * @author KeyMaster
 */
class FlxTrailAreaTest extends FlxSprite {
	/**
	 * How often the trail is updated
	 */
	public var delay:Int;
	
	/**
	 * If this is true, the render process ignores any color/scale/rotation manipulation of the sprites
	 * with the advantage of being faster
	 */
	public var simpleRender:Bool;
	
	/**
         * Specifies the blendMode for the trails
         * Ignored in simple render mode
         * Only works on the flash target
         */
	public var blendMode:BlendMode;
	
	/**
	 * If smoothing should be used for drawing the sprite
	 * Ignored in simple render mode
	 */
	public var smoothing:Bool;
	
	/**
	 * Stores all sprites that have a trail.
	 */
	public var group:FlxSpriteGroup;
	
	/**
	 * The bitmap's red value is multiplied by this every update
	 */
	public var redMultiplier:Float = 1;
	
	/**
	 * The bitmap's green value is multiplied by this every update
	 */
	public var greenMultiplier:Float = 1;
	
	/**
	 * The bitmap's blue value is multiplied by this every update
	 */
	public var blueMultiplier:Float = 1;
	
	/**
	 * The bitmap's alpha value is multiplied by this every update
	 */
	public var alphaMultiplier:Float;
	
	/**
	 * The bitmap's red value is offsettet by this every update
	 */
	public var redOffset:Float = 0;
	
	/**
	 * The bitmap's green value is offsettet by this every update
	 */
	public var greenOffset:Float = 0;
	
	/**
	 * The bitmap's blue value is offsettet by this every update
	 */
	public var blueOffset:Float = 0;
	
	/**
	 * The bitmap's alpha value is offsettet by this every update
	 */
	public var alphaOffset:Float = 0;
	
	/**
	 * The bitmap used internally for trail rendering.
	 */
	private var _renderBitmap:BitmapData;
	
	/**
	 * Counts the frames passed.
	 */
	private var _counter:Int = 0;
	
	 /**
	  * Creates a new <code>FlxTrailArea</code>
	  * 
	  * @param	Width		The width of the area
	  * @param	Height		The height of the area
	  * @param	AlphaMultiplier By what the area's alpha is multiplied per update
	  * @param	Delay		How often to update the trail. 0 updates every frame
	  * @param	SimpleRender If simple rendering should be used. Ignores all sprite transformations
	  * @param	Smoothing	If sprites should be smoothed when drawn to the area. Ignored when simple rendering is on
	  * @param	?TrailBlendMode The blend mode used for the area. Only works in flash
	  */
	public function new(Width:Int, Height:Int, AlphaMultiplier:Float = 0.8, Delay:Int = 1, SimpleRender:Bool = false, Smoothing:Bool = false, ?TrailBlendMode:BlendMode = null) {
		super();
		
		group = new FlxSpriteGroup();
		_renderBitmap = new BitmapData(Width, Height, 0x00000000);
		
		//Sync variables
		delay = Delay;
		simpleRender = SimpleRender;
		blendMode = TrailBlendMode;
		smoothing = Smoothing;
		alphaMultiplier = AlphaMultiplier;
		
	}
	
	override public function destroy():Void 
	{
		group = null;
		_renderBitmap = null;
		
		super.destroy();
	}
	
	override public function draw():Void 
	{
		//Count the frame
		_counter++;
		
		if (_counter >= delay) {
			_counter = 0;
			//Color transform bitmap
			var cTrans:ColorTransform = new ColorTransform(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
			_renderBitmap.colorTransform(new Rectangle(0, 0, _renderBitmap.width, _renderBitmap.height), cTrans);
			
			//Copy the graphics of all sprites on the renderBitmap
			var i:Int = 0;
			while (i < group.members.length) {
				if (group.members[i].exists) {
					if (simpleRender) {
							_renderBitmap.copyPixels(group.members[i].pixels, new Rectangle(0, 0, group.members[i].frameWidth, group.members[i].frameHeight), new Point(group.members[i].x - x, group.members[i].y - y), null, null, true);
					}
					else {
						var matrix:Matrix = new Matrix();
						matrix.scale(group.members[i].scale.x, group.members[i].scale.y);
						matrix.translate(-(group.members[i].frameWidth / 2), -(group.members[i].frameHeight / 2)); 
						matrix.rotate(-group.members[i].angle * FlxAngle.TO_RAD);
						matrix.translate((group.members[i].frameWidth / 2), (group.members[i].frameHeight / 2)); 
						matrix.translate(group.members[i].x - x, group.members[i].y - y);
						_renderBitmap.draw(group.members[i].pixels, matrix, group.members[i].colorTransform, blendMode, null, smoothing);
					}
					
				}
				i++;
			}
			//Apply the updated bitmap
			pixels = _renderBitmap;
		}
		super.draw();
	}
	
	/**
	 * Wipes the trail area
	 */
	public function resetTrail():Void {
		_renderBitmap.fillRect(new Rectangle(0, 0, _renderBitmap.width, _renderBitmap.height), 0x00000000);
	}
	
	/**
	 * Adds a <code>FlxSprite</code> to the <code>FlxTrailArea</code>
	 * @param	Sprite		The sprite to add
	 */
	public function add(Sprite:FlxSprite):FlxSprite {
		return group.add(Sprite);
	}
	
	
}
