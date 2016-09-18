package flixel.util;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;

// TODO: implement it...

/**
 * I need this class for flash target with stage3D support
 * @author Zaphod
 */
class FlxBitmapData extends BitmapData
{
	public var texture(get, null):Texture;
	
	private var _dirty:Bool = true;;
	
	public function new(width:Int, height:Int, transparent:Bool = true, fillColor:UInt = 0xFFFFFFFF) 
	{
		super(width, height, transparent, fillColor);
	}
	
	override public function dispose():Void 
	{
		if (texture != null)
		{
			texture.dispose();
			texture = null;
		}
		
		super.dispose();
	}
	
	private function get_texture():Texture
	{
		if (_dirty)
		{
			
		}
		
		_dirty = false;
		return null;
	}
	
}