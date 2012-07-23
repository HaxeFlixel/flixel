package org.flixel;

#if (cpp || neko)
import org.flixel.FlxBasic;
import org.flixel.system.tileSheet.atlasgen.Atlas;
#end

class FlxLayer extends FlxGroup
{	
	
	#if (cpp || neko)
	private var _atlas:Atlas;
	#else
	
	public function new(?MaxSize:Int = 0)
	{
		super(MaxSize);
	}
	
	public function createAtlas(TextureWidth:Int, TextureHeight:Int):Void
	{
		#if (cpp || neko)
		if (TextureWidth > 0 && TextureHeight > 0)
		{
			_atlas = new Atlas(TextureWidth, TextureHeight, 1, 1);
		}
		#end
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		#if (cpp || neko)
		if (_atlas != null)
		{
			_atlas.destroy();
		}
		#end
	}
	
	override public function add(Object:FlxBasic):FlxBasic
	{
		return super.add(Object);
	}
	
	override public function recycle(?ObjectClass:Class<FlxBasic> = null):FlxBasic 
	{
		return super.recycle(?ObjectClass);
	}
	
	public function addWithBaking(Object:FlxBasic):FlxBasic
	{
		return add(Object);
	}
	
	public function recycleWithBaking(?ObjectClass:Class<FlxBasic> = null):FlxBasic
	{
		return recycle(ObjectClass);
	}
	
}