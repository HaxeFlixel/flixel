package org.flixel.addons;

import nme.display.Sprite;
import org.flixel.FlxSprite;
import org.flixel.FlxTypedGroup;

class FlxSpriteGroup extends FlxTypedGroup<FlxSprite>
{
    private var _x:Float = 0;
    private var _y:Float = 0;
    private var _alpha:Float = 1;
	
	public var x(get_x, set_x):Float;

    private function get_x():Float 
	{
		return _x;
	}
	
    private function set_x(nx:Float):Float
    {
        var offset:Float = nx - _x;
        transformChildren(xTransform, offset);
        _x = nx;
		return nx;
    }
	
	public var y(get_y, set_y):Float;
	
    private function get_y():Float 
	{ 
		return _y;
	}
	
    private function set_y(ny:Float):Float
    {
        var offset:Float = ny - _y;
        transformChildren(yTransform, offset);
        _y = ny;
		return ny;
    }
	
	public var alpha(get_alpha, set_alpha):Float;
	
    private function get_alpha():Float
	{ 
		return _alpha; 
	}
	
    private function set_alpha(n:Float):Float 
    {
        _alpha = n;
        if (_alpha > 1)  _alpha = 1;
        else if (_alpha < 0)  _alpha = 0;
        transformChildren(alphaTransform, _alpha);
		return n;
    }
	
	public function move(newX:Float, newY:Float):Void
	{
		var xOffset:Float = newX - _x;
		var yOffset:Float = newY - _y;
		var valueArr:Array<Dynamic> = [xOffset, yOffset];
		var lambdaArr:Array<FlxSprite->Dynamic->Void> = [xTransform, yTransform];
		multiTransformChildren(lambdaArr, valueArr);
		_x = newX;
		_y = newY;
	}

    private function transformChildren(lambda:FlxSprite->Dynamic->Void, value:Dynamic = 0):Void
    {
        var sprite:FlxSprite;
        var i:Int = 0;
        while(i < length)
        {
            sprite = members[i++];
            if (sprite != null)
            {
				lambda(sprite, value);
			}
        }
    }
	
	private function multiTransformChildren(lambdaArr:Array<FlxSprite->Dynamic->Void>, valueArr:Array<Dynamic>):Void
    {
        var numProps:Int = lambdaArr.length;
		if (numProps > valueArr.length)
		{
			return;
		}
		
		var sprite:FlxSprite;
		var lambda:FlxSprite->Dynamic->Void;
        var i:Int = 0;
		var j:Int;
        while(i < length)
        {
            sprite = members[i++];
            if (sprite != null)
            {
				for (j in 0...numProps)
				{
					lambda = lambdaArr[j];
					lambda(sprite, valueArr[j]);
				}
			}
        }
    }
	
	private function xTransform(s:FlxSprite, dx:Dynamic):Void
	{
		s.x += dx;
	}
	
	private function yTransform(s:FlxSprite, dy:Dynamic):Void
	{
		s.y += dy;
	}
	
	private function alphaTransform(s:FlxSprite, a:Dynamic):Void
	{
		s.alpha = a;
	}
}