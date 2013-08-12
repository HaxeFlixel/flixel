package flixel.group;

import flixel.FlxSprite;
import flixel.util.FlxPoint;

/**
 * <code>FlxSpriteGroup</code> is a special <code>FlxGroup</code>
 * that can be treated like a <code>FlxSprite</code> due to having
 * x, y and alpha values. It can only contain <code>FlxSprites</code>.
 */
class FlxSpriteGroup extends FlxTypedGroup<IFlxSprite> implements IFlxSprite
{
    /**
     * This field is added to match se IFlxSprite structure, if it needs to update children todo: update scrollFactor for children
     **/
    public var scrollFactor:FlxPoint;

    /**
     * This field is added to match se IFlxSprite structure, if it needs to update children todo: update it for children
     **/
    public var angle(default, set):Float = 0;

    private function set_angle(Value:Float):Float
    {
        return Value;//do nothing, if will be needed - set the value for all child sprites
    }
    /**
     * This field is added to match se IFlxSprite structure, if it needs to update children todo: update it for children
     **/
    public var origin:FlxPoint;
    /**
     * This field is added to match se IFlxSprite structure, if it needs to update children todo: update it for children
     **/
    public var scale:FlxPoint;

    /**
     * This field is added to match se IFlxSprite structure, if it needs to update children todo: update it for children
     **/
    public var frame(default, set):Int;

    private function set_frame(Frame:Int):Int
    {
    	return Frame; //do nothing, if will be needed - set the value for all child sprites
    }
    /**
     * This field is added to match se IFlxSprite structure, if it needs to update children todo: update it for children
     **/
    public var facing(default, set):Int;
    private function set_facing(Direction:Int):Int
    {
        return Direction;
    }

    @:isVar public var solid(get, set):Bool = false;

   	private function get_solid():Bool
   	{
   		return solid;
   	}

   	private function set_solid(Solid:Bool):Bool
   	{
        return solid=Solid;
   	}


    /**
     * This field is added to match se IFlxSprite structure, if it needs to update children todo: update it for children
     **/
    public function loadGraphic(Graphic:Dynamic, Animated:Bool = false, Reverse:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite {
        return null;
    }

    /**
	 * Optimization to allow setting position of group without transforming children twice.
	 */
	private var _skipTransformChildren:Bool = false;
	
	/**
	 * Adds a new <code>FlxBasic</code> subclass (FlxBasic, FlxSprite, Enemy, etc) to the group.
	 * FlxGroup will try to replace a null member of the array first.
	 * Object is translated to coordinates relative to group.
	 * Failing that, FlxGroup will add it to the end of the member array,
	 * assuming there is room for it, and doubling the size of the array if necessary.
	 * WARNING: If the group has a maxSize that has already been met,
	 * the object will NOT be added to the group!
	 * 
	 * @param	Object		The object you want to add to the group.
	 * @return	The same <code>FlxBasic</code> object that was passed in.
	 */
	override public function add(Sprite:IFlxSprite):IFlxSprite
	{
		Sprite.x += x;
		Sprite.y += y;
		Sprite.alpha = alpha;
		
		return super.add(Sprite);
	}
	
	/**
	 * The x position of this group.
	 */
	public var x(default, set):Float = 0;
	
	private function set_x(NewX:Float):Float
	{
		if (!_skipTransformChildren)
		{
			var offset:Float = NewX - x;
			transformChildren(xTransform, offset);
		}
		
		return x = NewX;
	}
	
	/**
	 * The y position of this group.
	 */
	public var y(default, set):Float = 0;
	
	private function set_y(NewY:Float):Float
	{
		#if neko
		if (y == null)
		{
			y = 0;
		}
		#end
		
		if (!_skipTransformChildren)
		{
			var offset:Float = NewY - y;
			transformChildren(yTransform, offset);
		}
		
		return y = NewY;
	}
	
	/**
	 * The alpha value of this group.
	 */
	public var alpha(default, set):Float = 1;
	
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
		
		if (!_skipTransformChildren)
		{
			transformChildren(alphaTransform, alpha);
		}
		
		return NewAlpha;
	}
	
	/**
	 * Helper function to set the coordinates of this object.
	 * Handy since it only requires one line of code.
	 * 
	 * @param	X	The new x position
	 * @param	Y	The new y position
	 */
	public function setPosition(X:Float, Y:Float):Void
	{
		var dx:Float = X - x;
		var dy:Float = Y - y;
		multiTransformChildren([xTransform, yTransform], [dx, dy]);
		
		// don't transform children twice
		_skipTransformChildren = true;
		x = X; // this calls set_x
		y = Y; // this calls set_y
		_skipTransformChildren = false;
	}
	
	/**
	 * Handy function that allows you to quickly transform one property of sprites in this group at a time.
	 * 
	 * @param 	Function 	Function to transform the sprites. Example: <code>function(s:IFlxSprite, v:Dynamic) { s.acceleration.x = v; s.makeGraphic(10,10,0xFF000000); }</code>
	 * @param 	Value  		Value which will passed to lambda function
	 */
	public function transformChildren(Function:IFlxSprite->Dynamic->Void, Value:Dynamic = 0):Void
	{
		var sprite:IFlxSprite;
		
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
	public function multiTransformChildren(FunctionArray:Array<IFlxSprite->Dynamic->Void>, ValueArray:Array<Dynamic>):Void
	{
		var numProps:Int = FunctionArray.length;
		
		if (numProps > ValueArray.length)
		{
			return;
		}
		
		var sprite:IFlxSprite;
		var lambda:IFlxSprite->Dynamic->Void;
		
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
	private function xTransform(Sprite:IFlxSprite, X:Float):Void
	{
		Sprite.x += X;
	}
	
	/**
	 * Helper function for transformation of sprite's y coordinate
	 * 
	 * @param	Sprite	Sprite to manipulate
	 * @param	Y		Value to add to sprite's y coordinate
	 */
	private function yTransform(Sprite:IFlxSprite, Y:Float):Void
	{
		Sprite.y += Y;
	}
	
	/**
	 * Helper function for transformation of sprite's alpha coordinate
	 * 
	 * @param	Sprite		Aprite to manipulate
	 * @param	NewAlpha	Alpha value to set
	 */
	private function alphaTransform(Sprite:IFlxSprite, NewAlpha:Float):Void
	{
		Sprite.alpha = NewAlpha;
	}
}