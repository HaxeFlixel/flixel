package org.flixel.plugin.texturepacker;

import org.flixel.system.layer.Atlas;
import org.flixel.system.layer.TileSheetData;
import nme.display.BitmapData;

class TexturePackerAtlas extends Atlas
{
	public static function getAtlas(key:String, bmData:BitmapData, tex:TexturePackerData, unique:Bool = false):TexturePackerAtlas
	{
		var alreadyExist:Bool = Atlas.isExists(key);
		var isTexurePacker:Bool = false;
		
		var cachedAtlas:Atlas = Atlas.getAtlasByKey(key);
		if (Std.is(cachedAtlas, TexturePackerAtlas))
		{
			isTexurePacker = true;
		}
		
		if (!unique && alreadyExist && isTexurePacker)
		{
			return cast(Atlas.getAtlas(key, bmData, unique), TexturePackerAtlas);
		}
		
		var atlasKey:String = key;
		if (alreadyExist && (unique || !isTexurePacker))
		{
			atlasKey = Atlas.getUniqueKey(key);
		}
		// TODO: change constructor signature
		var atlas:TexturePackerAtlas = new TexturePackerAtlas(atlasKey, bmData.width, bmData.height, 1, 1, bmData, tex);
		return atlas;
	}

	private var _tex:TexturePackerData;
	
	private function new(name:String, width:Int, height:Int, borderX:Int = 1, borderY:Int = 1, bitmapData:BitmapData = null, tex:TexturePackerData = null)
	{
		_tex = tex;
		super(name, width, height, borderX, borderY, bitmapData);
	}

	override public function createTileSheetData(bitmapData:BitmapData):TileSheetData
	{
		return TexturePackerTileSheetData.addTileSheet(bitmapData, _tex);
	}
}