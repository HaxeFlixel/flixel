package flixel.addons;

import flash.display.Sprite;
import flixel.FlxSprite;
import flixel.FlxTypedGroup;

/**
 * <code>FlxSpriteGroup</code> is a special <code>FlxGroup</code>
 * that can be treated like a <code>FlxSprite</code> due to having
 * x, y and alpha values. It can only contain <code>FlxSprites</code>.
 */
class FlxSpriteGroup extends FlxTypedGroup<FlxSprite>
{
	/**
	 * The x position of this group.
	 */
	public var x(default, set_x):Float;
	
    private function set_x(nx:Float):Float
    {
        #if neko
		if (x == null)	x = 0;
		#end
		var offset:Float = nx - x;
        transformChildren(xTransform, offset);
        x = nx;
		return nx;
    }
	
	/**
	 * The y position of this group.
	 */
	public var y(default, set_y):Float;
	
    private function set_y(ny:Float):Float
    {
        #if neko
		if (y == null)	y = 0;
		#end
		var offset:Float = ny - y;
        transformChildren(yTransform, offset);
        y = ny;
		return ny;
    }
	
	/**
	 * The alpha value of this group.
	 */
	public var alpha(default, set_alpha):Float;
	
    private function set_alpha(n:Float):Float 
    {
        alpha = n;
        if (alpha > 1)  alpha = 1;
        else if (alpha < 0)  alpha = 0;
        transformChildren(alphaTransform, alpha);
		return n;
    }
	
	public function new(MaxSize:Int = 0)
	{
		super(MaxSize);

		x = 0;
		y = 0;
		alpha = 1;
	}
	
	public function move(newX:Float, newY:Float):Void
	{
		var xOffset:Float = newX - x;
		var yOffset:Float = newY - y;
		var valueArr:Array<Dynamic> = [xOffset, yOffset];
		var lambdaArr:Array<FlxSprite->Dynamic->Void> = [xTransform, yTransform];
		multiTransformChildren(lambdaArr, valueArr);
		x = newX;
		y = newY;
	}
	
	/**
	 * Handy function that allows you to quickly transform one property of sprites in this group at a time.
	 * @param lambda Function to transform the sprites. Example: function(s:FlxSprite, v:Dynamic) { s.acceleration.x = v; s.makeGraphic(10,10,0xFF000000); }
	 * @param value  Value which will passed to lambda function
	 */
    public function transformChildren(lambda:FlxSprite->Dynamic->Void, value:Dynamic = 0):Void
    {
        var sprite:FlxSprite;
        for (i in 0...length)
        {
            sprite = members[i];
            if (sprite != null && sprite.exists)
            {
				lambda(sprite, value);
			}
        }
    }
	
	/**
	 * Handy function that allows you to quickly transform multiple properties of sprites in this group at a time.
	 * @param	lambdaArr	Array of functions to transform sprites in this group.
	 * @param	valueArr	Array of values which will be passed to lambda functions
	 */
	public function multiTransformChildren(lambdaArr:Array<FlxSprite->Dynamic->Void>, valueArr:Array<Dynamic>):Void
    {
        var numProps:Int = lambdaArr.length;
		if (numProps > valueArr.length)
		{
			return;
		}
		
		var sprite:FlxSprite;
		var lambda:FlxSprite->Dynamic->Void;
		var j:Int;
        for (i in 0...length)
        {
            sprite = members[i];
            if (sprite != null && sprite.exists)
            {
				for (j in 0...numProps)
				{
					lambda = lambdaArr[j];
					lambda(sprite, valueArr[j]);
				}
			}
        }
    }
	
	/**
	 * Helper function for transformation of sprite's x coordinate
	 * @param	s	sprite to manipulate
	 * @param	dx	value to add to sprite's x coordinate
	 */
	private function xTransform(s:FlxSprite, dx:Float):Void
	{
		s.x += dx;
	}
	
	/**
	 * Helper function for transformation of sprite's y coordinate
	 * @param	s	sprite to manipulate
	 * @param	dx	value to add to sprite's y coordinate
	 */
	private function yTransform(s:FlxSprite, dy:Float):Void
	{
		s.y += dy;
	}
	
	/**
	 * Helper function for transformation of sprite's alpha coordinate
	 * @param	s	sprite to manipulate
	 * @param	dx	alpha value to set
	 */
	private function alphaTransform(s:FlxSprite, a:Float):Void
	{
		s.alpha = a;
	}
}