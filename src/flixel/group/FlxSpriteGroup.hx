package flixel.group;

import flixel.FlxSprite;

/**
 * <code>FlxSpriteGroup</code> is a special <code>FlxGroup</code>
 * that can be treated like a <code>FlxSprite</code> due to having
 * x, y and alpha values. It can only contain <code>FlxSprites</code>.
 */
class FlxSpriteGroup extends FlxTypedGroup<FlxSprite>
{
	public function new(MaxSize:Int = 0)
	{
		super(MaxSize);
		
		x = 0;
		y = 0;
		alpha = 1;
	}
	
	/**
	 * The x position of this group.
	 */
	public var x(default, set):Float;
	
    private function set_x(NewX:Float):Float
    {
        #if neko
		if (x == null)	
		{
			x = 0;
		}
		#end
		
		var offset:Float = NewX - x;
        transformChildren(xTransform, offset);
		
		return x = NewX;
    }
	
	/**
	 * The y position of this group.
	 */
	public var y(default, set):Float;
	
    private function set_y(NewY:Float):Float
    {
        #if neko
		if (y == null)	
		{
			y = 0;
		}
		#end
		
		var offset:Float = NewY - y;
        transformChildren(yTransform, offset);
		
		return y = NewY;
    }
	
	/**
	 * The alpha value of this group.
	 */
	public var alpha(default, set):Float;
	
    private function set_alpha(NewAlpha:Float):Float 
    {
        alpha = NewAlpha;
		
        if (alpha > 1)  
		{
			alpha = 1;
		}
        else if (alpha < 0)  
		{
			alpha = 0;
		}
		
        transformChildren(alphaTransform, alpha);
		
		return NewAlpha;
    }
	
	public function move(NewX:Float, NewY:Float):Void
	{
		var xOffset:Float = NewX - x;
		var yOffset:Float = NewY - y;
		
		var valueArr:Array<Dynamic> = [xOffset, yOffset];
		var lambdaArr:Array < FlxSprite-> Dynamic->Void > = [xTransform, yTransform];
		
		multiTransformChildren(lambdaArr, valueArr);
		
		x = NewX;
		y = NewY;
	}
	
	/**
	 * Handy function that allows you to quickly transform one property of sprites in this group at a time.
	 * 
	 * @param 	Function 	Function to transform the sprites. Example: <code>function(s:FlxSprite, v:Dynamic) { s.acceleration.x = v; s.makeGraphic(10,10,0xFF000000); }</code>
	 * @param 	Value  		Value which will passed to lambda function
	 */
    public function transformChildren(Function:FlxSprite->Dynamic->Void, Value:Dynamic = 0):Void
    {
        var sprite:FlxSprite;
		
        for (i in 0...length)
        {
            sprite = members[i];
			
            if (sprite != null && sprite.exists)
            {
				Function(sprite, Value);
			}
        }
    }
	
	/**
	 * Handy function that allows you to quickly transform multiple properties of sprites in this group at a time.
	 * 
	 * @param	FunctionArray	Array of functions to transform sprites in this group.
	 * @param	ValueArray		Array of values which will be passed to lambda functions
	 */
	public function multiTransformChildren(FunctionArray:Array<FlxSprite->Dynamic->Void>, ValueArray:Array<Dynamic>):Void
    {
        var numProps:Int = FunctionArray.length;
		
		if (numProps > ValueArray.length)
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
					lambda = FunctionArray[j];
					lambda(sprite, ValueArray[j]);
				}
			}
        }
    }
	
	/**
	 * Helper function for transformation of sprite's x coordinate
	 * 
	 * @param	Sprite	Sprite to manipulate
	 * @param	X		Value to add to sprite's x coordinate
	 */
	private function xTransform(Sprite:FlxSprite, X:Float):Void
	{
		Sprite.x += X;
	}
	
	/**
	 * Helper function for transformation of sprite's y coordinate
	 * 
	 * @param	Sprite	Sprite to manipulate
	 * @param	Y		Value to add to sprite's y coordinate
	 */
	private function yTransform(Sprite:FlxSprite, Y:Float):Void
	{
		Sprite.y += Y;
	}
	
	/**
	 * Helper function for transformation of sprite's alpha coordinate
	 * 
	 * @param	Sprite		Aprite to manipulate
	 * @param	NewAlpha	Alpha value to set
	 */
	private function alphaTransform(Sprite:FlxSprite, NewAlpha:Float):Void
	{
		Sprite.alpha = NewAlpha;
	}
}