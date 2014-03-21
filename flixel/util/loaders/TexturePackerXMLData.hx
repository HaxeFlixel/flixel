package flixel.util.loaders;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.interfaces.IFlxDestroyable;
import flixel.util.FlxPoint;
import haxe.Json;
import haxe.xml.Fast;
import openfl.Assets;

class TexturePackerXMLData extends TexturePackerData implements IFlxDestroyable
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
		var xml = Xml.parse(Assets.getText(description));
		var root = xml.firstElement();
		
		for (sprite in root.elements())
		{
			var texFrame:TextureAtlasFrame = new TextureAtlasFrame();
			texFrame.trimmed = false; // trimmed images aren't supported yet
			texFrame.rotated = (sprite.exists("r") && sprite.get("r") == "y");
			
			texFrame.additionalAngle = (texFrame.rotated) ? -90 : 0;
			
			texFrame.name = sprite.get("n");
			
			texFrame.offset = FlxPoint.get(0, 0);
			
			texFrame.frame = new Rectangle(	
											Std.parseInt(sprite.get("x")),
											Std.parseInt(sprite.get("y")),
											Std.parseInt(sprite.get("w")),
											Std.parseInt(sprite.get("h"))
										);
			
			texFrame.sourceSize = FlxPoint.get(texFrame.frame.width, texFrame.frame.height);	
			
			frames.push(texFrame);
		}
	}
}