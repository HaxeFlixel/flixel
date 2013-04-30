package org.flixel.plugin.texturepacker;

import org.flixel.FlxSprite;
import org.flixel.plugin.texturepacker.TexturePackerData;
import org.flixel.system.layer.frames.TexturePackerFrame;

#if !flash
import org.flixel.plugin.texturepacker.TexturePackerAtlas;
import org.flixel.system.layer.Atlas;
#end

import nme.geom.Point;
import nme.geom.Rectangle;
import nme.display.BitmapData;

class FlxSpriteTex extends FlxSprite
{
	var _tex:TexturePackerData;
	var _spriteId:Int;
	
	public function new(x:Float, y:Float, spriteName:String, tex:TexturePackerData)
	{
		_tex = tex;
		_spriteId = tex.frames.get(spriteName);
#if !flash
		super(x, y, tex.assetName);
#else
		super(x, y);
		
		var spriteInfo:TexturePackerFrame = _tex.sprites[_spriteId];
		var bm:BitmapData = spriteInfo.getBitmap();
		loadGraphic(bm, false, false, 0, 0, false, _tex.assetName + spriteName);
#end
	}
	
	override private function resetHelpers():Void
	{
#if !flash
		var spriteInfo:TexturePackerFrame = _tex.sprites[_spriteId];
		width = frameWidth = Std.int(spriteInfo.sourceSize.x);
		height = frameHeight = Std.int(spriteInfo.sourceSize.y);
		
		offset = spriteInfo.offset;
		if (spriteInfo.rotated)
		{
			_additionalAngle = -90.0;
		}
		
		trace(offset.x + "; " + offset.y);
#end
		super.resetHelpers();
	}

#if !flash
	override public function getAtlas():Atlas
	{
		var bm:BitmapData = FlxG._cache.get(_bitmapDataKey);
		if (bm != null)
		{
			return TexturePackerAtlas.getAtlas(_bitmapDataKey, bm, _tex);
		}
		else
		{
	#if !FLX_NO_DEBUG
			throw "There isn't bitmapdata in cache with key: " + _bitmapDataKey;
	#end
		}
		
		return null;
	}
#end

	override public function updateFrameData():Void
	{
#if !flash
		_framesData = _node.getSpriteSheetFrames(Std.int(width), Std.int(height));
		_flxFrame = _framesData.frames[_spriteId];
#else
		super.updateFrameData();
#end
	}
}