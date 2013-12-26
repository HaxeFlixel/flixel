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
class FlxTrailArea extends FlxSprite {
	/**
	 * The factor by which the area's alpha is multiplied by every update.
	 */
	public var alphaFactor:Float;
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
	 * Not sure if this really does anything
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
	private var _group:FlxSpriteGroup;
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
	 * @param	FadeSpeed		The height of the area
	 * @param	Delay		How often to update the trail. 0 updates every frame.
	 */
	public function new(Width:Int, Height:Int, AlphaFactor:Float = 0.8, Delay:Int = 1, SimpleRender:Bool = false, ?TrailBlendMode:BlendMode = null, Smoothing:Bool = false) {
		super();
		
		//makeGraphic(Width, Height, 0x00000000);
		_group = new FlxSpriteGroup();
		_renderBitmap = new BitmapData(Width, Height, 0x00000000);
		
		//Sync variables
		alphaFactor = AlphaFactor;
		delay = Delay;
		simpleRender = SimpleRender;
		blendMode = TrailBlendMode;
		smoothing = Smoothing;
	}
	
	override public function destroy():Void 
	{
		_group = null;
		_renderBitmap = null;
		
		super.destroy();
	}
	
	override public function draw():Void 
	{
		//Count the frame
		_counter++;
		
		if (_counter >= delay) {
			_counter = 0;
			//Fade out the bitmap
			var cTrans:ColorTransform = new ColorTransform(1, 1, 1, alphaFactor);
			_renderBitmap.colorTransform(new Rectangle(0, 0, _renderBitmap.width, _renderBitmap.height), cTrans);
			
			//Copy the graphics of all sprites on the renderBitmap
			var i:Int = 0;
			while (i < _group.members.length) {
				if (_group.members[i].exists) {
					if (simpleRender) {
							_renderBitmap.copyPixels(_group.members[i].pixels, new Rectangle(0, 0, _group.members[i].frameWidth, _group.members[i].frameHeight), new Point(_group.members[i].x - x, _group.members[i].y - y), null, null, true);
					}
					else {
						var matrix:Matrix = new Matrix();
						matrix.scale(_group.members[i].scale.x, _group.members[i].scale.y);
						matrix.translate(-(_group.members[i].frameWidth / 2), -(_group.members[i].frameHeight / 2)); 
						matrix.rotate(-_group.members[i].angle * FlxAngle.TO_RAD);
						matrix.translate((_group.members[i].frameWidth / 2), (_group.members[i].frameHeight / 2)); 
						matrix.translate(_group.members[i].x - x, _group.members[i].y - y);
						_renderBitmap.draw(_group.members[i].pixels, matrix, _group.members[i].colorTransform, blendMode, null, smoothing);
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
	public function clear():Void {
		_renderBitmap.fillRect(new Rectangle(0, 0, _renderBitmap.width, _renderBitmap.height), 0x00000000);
	}
	
	/**
	 * Adds a <code>FlxSprite</code> to the <code>FlxTrailArea</code>
	 * @param	Sprite		The sprite to add
	 */
	public function add(Sprite:FlxSprite):Void {
		_group.add(Sprite);
	}
	
	
}
