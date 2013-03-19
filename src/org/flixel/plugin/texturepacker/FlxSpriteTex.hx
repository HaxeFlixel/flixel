package org.flixel.plugin.texturepacker;

import org.flixel.FlxSprite;
import org.flixel.plugin.texturepacker.TexturePackerFrames;

#if !flash
import org.flixel.plugin.texturepacker.TexturePackerAtlas;
import org.flixel.system.layer.Atlas;
#end

import nme.geom.Point;
import nme.geom.Rectangle;
import nme.display.BitmapData;

class FlxSpriteTex extends FlxSprite
{
	var _tex:TexturePackerFrames;
	var _spriteId:Int;
	
	public function new(x:Float, y:Float, spriteName:String, tex:TexturePackerFrames)
	{
		_tex = tex;
		_spriteId = tex.frames.get(spriteName);
#if !flash
		super(x, y, tex.assetName);
#else
		super(x, y);
		
		var spriteInfo:TexturePackerSprite = _tex.sprites[_spriteId];
		var bm:BitmapData = new BitmapData(Std.int(spriteInfo.source.width), Std.int(spriteInfo.source.height), true, 0x00ffffff);
		
		if (spriteInfo.rotated)
		{
			_matrix.identity();
			_matrix.translate(-spriteInfo.source.width * 0.5, -spriteInfo.source.height * 0.5);
			_matrix.rotate(-90.0 * FlxG.RAD);
			_matrix.translate(spriteInfo.source.width * 0.5, spriteInfo.source.height * 0.5);
			_matrix.translate(spriteInfo.offset.x, spriteInfo.offset.y);
			
			var r:Rectangle = new Rectangle(spriteInfo.frame.x, spriteInfo.frame.y, spriteInfo.frame.width + spriteInfo.offset.x, spriteInfo.frame.height + spriteInfo.offset.y);
			bm.draw(_tex.asset, _matrix, null, null, r, false);
		}
		else
		{
			var dst:Point = new Point(spriteInfo.offset.x, spriteInfo.offset.y);
			bm.copyPixels(_tex.asset, spriteInfo.frame, dst);
		}
		
		loadGraphic(bm, false, false, 0, 0, false, _tex.assetName + spriteName);
#end
	}
	
	override private function resetHelpers():Void
	{
#if !flash
		var spriteInfo:TexturePackerFrame = _tex.sprites[_spriteId];
		width = frameWidth = Std.int(spriteInfo.source.width);
		height = frameHeight = Std.int(spriteInfo.source.height);
		offset = spriteInfo.offset;
		if (spriteInfo.rotated)
		{
			_additionalAngle = -90.0;
		}
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