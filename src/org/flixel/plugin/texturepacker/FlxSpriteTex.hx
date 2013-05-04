package org.flixel.plugin.texturepacker;

import org.flixel.FlxSprite;
import org.flixel.plugin.texturepacker.TexturePackerData;
import org.flixel.system.layer.frames.FlxFrame;

#if !flash
import org.flixel.system.layer.Atlas;
#end

import nme.geom.Point;
import nme.geom.Rectangle;
import nme.display.BitmapData;

class FlxSpriteTex extends FlxSprite
{
	var _tex:TexturePackerData;
	var _spriteName:String;
	
	public function new(x:Float, y:Float, spriteName:String, tex:TexturePackerData)
	{
		_tex = tex;
		_spriteName = spriteName;
#if !flash
		super(x, y, tex.assetName);
#else
		super(x, y);
		
		//var spriteInfo:TexturePackerFrame = _tex.sprites[_spriteId];
		var spriteInfo:FlxFrame = _tex.tileSheetData.getFrame(_spriteName);
		var bm:BitmapData = spriteInfo.getBitmap();
		loadGraphic(bm, false, false, 0, 0, false, _tex.assetName + spriteName);
#end
	}

	override public function updateFrameData():Void
	{
#if !flash
		//_framesData = _node.getSpriteSheetFrames(Std.int(width), Std.int(height));
		_framesData = _node.getTexturePackerFrames(_tex);
		
		var spriteInfo:FlxFrame = _atlas._tileSheetData.getFrame(_spriteName);
		width = frameWidth = Std.int(spriteInfo.sourceSize.x);
		height = frameHeight = Std.int(spriteInfo.sourceSize.y);
		
	//	offset = spriteInfo.offset;
		
		resetHelpers();
		
		//_flxFrame = _framesData.frames[_spriteId];
		_flxFrame = _atlas._tileSheetData.getFrame(_spriteName);
#else
		super.updateFrameData();
#end
	}
}