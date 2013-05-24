package org.flixel.addons;

import org.flixel.FlxTypedGroup;
import org.flixel.FlxSprite;

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
	/**
	* The y position of this group.
	*/
    public var y(default, set_y):Float;
	/**
	* The alpha value of this group.
	*/
    public var alpha(default, set_alpha):Float;

	public function new(MaxSize:Int = 0)
	{
		super(MaxSize);
		
		x = 0;
		y = 0;
		alpha = 1;
	}
	
    private function set_x(nx:Float):Float
    {
        var offset = nx - x;
		x = nx;
		
        transformChildren(function(s:FlxSprite) { s.x += offset; });
        
		return x;
    }

    private function set_y(ny:Float):Float
    {
        var offset = ny - y;
		y = ny;
		
        transformChildren(function(s:FlxSprite) { s.y += offset; });
		
		return y;
    }

    private function set_alpha(n:Float):Float 
    {
		alpha = n;
		
        if (alpha > 1)  alpha = 1;
        else if (alpha < 0)  alpha = 0;
		
        transformChildren(function(s:FlxSprite) { s.alpha = alpha; } );
		
		return alpha;
    }

	/**
	* Handy function that allows you to quickly transform sprites in this group.
	* @param	lambda	Function to transform the sprites. Example: function(s:FlxSprite) { s.acceleration.x = 200; s.makeGraphic(10,10,0xFF000000); }
	*/
    public function transformChildren(lambda:FlxSprite -> Void):Void
    {
        var sprite:FlxSprite;
        var i:Int = 0;
        while(i < length)
        {
            sprite = members[i++];
            if (sprite != null && sprite.exists)
                lambda(sprite);
        }
    }
}