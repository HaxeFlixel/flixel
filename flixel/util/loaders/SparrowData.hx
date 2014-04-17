package flixel.util.loaders;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.interfaces.IFlxDestroyable;
import flixel.util.FlxPoint;
import haxe.Json;
import haxe.xml.Fast;
import openfl.Assets;

class SparrowData extends TexturePackerData
{
	/**
	 * Constructor
	 * 
	 * @param	Description		Name of the data file with atlas description
	 * @param	AssetName		Name of the atlas image file
	 */
	public function new(Description:String, AssetName:String)
	{
		super(Description, AssetName);
	}
	
	/**
	 * Data parsing method.
	 * Override it in subclasses if you want to implement support for new atlas formats
	 */
	override public function parseData():Void
	{
		// No need to parse data again
		if (frames.length != 0)	return;
		
		if ((assetName == null) || (description == null)) return;
		
		asset = FlxG.bitmap.add(assetName).bitmap;
		var data:Fast = new haxe.xml.Fast(Xml.parse(Assets.getText(description)).firstElement());
		
		for (texture in data.nodes.SubTexture)
		{
			var texFrame:TextureAtlasFrame = new TextureAtlasFrame();
			texFrame.trimmed = texture.has.frameX;
			texFrame.rotated = false;
			texFrame.name = texture.att.name;
			
			var rect:Rectangle = new Rectangle(
				Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y),
				Std.parseFloat(texture.att.width), Std.parseFloat(texture.att.height));
			
			var size:Rectangle = if (texFrame.trimmed) // trimmed
					new Rectangle(
						Std.parseInt(texture.att.frameX), Std.parseInt(texture.att.frameY),
						Std.parseInt(texture.att.frameWidth), Std.parseInt(texture.att.frameHeight));
				else 
					new Rectangle(0, 0, rect.width, rect.height);
			
			texFrame.offset = FlxPoint.get(0, 0);
			texFrame.offset.set(-size.left, -size.top);
			
			texFrame.sourceSize = FlxPoint.get(size.width, size.height);	
			texFrame.frame = rect;
			
			frames.push(texFrame);
		}
	}
}