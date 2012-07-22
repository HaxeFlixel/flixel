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
	
	public function new(?TextureWidth:Int = 0, ?TextureHeight:Int = 0, ?MaxSize:Int = 0)
	{
		super(MaxSize);
		
		#if (cpp || neko)
		if (TextureWidth != 0 && TextureHeight != 0)
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
		var basic:FlxBasic = super.add(Object);
		
		#if (cpp || neko)
		if (_atlas != null)
		{
			
		}
		#end
		
		return basic;
	}
	
}