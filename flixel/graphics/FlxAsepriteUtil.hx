package flixel.graphics;

import flixel.graphics.atlas.AseAtlas;
import flixel.animation.FlxAnimationController;
import flixel.math.FlxMath;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;

/**
 * Collection of helpers that deal with Aseprite files. Namely the json files exported for sprite sheets.
 */
class FlxAsepriteUtil
{
	/**
	 * Helper for parsing Aseprite atlas json files. Reads frames via `FlxAtlasFrames.fromAseprite`.
	 * 
	 * @param   sprite   The sprite to load the ase atlas's frames
	 * @param   graphic  The png file associated with the atlas
	 * @param   data       Can be an `AseAtlas` struct, a JSON string matching the `AseAtlas` or a
	 *                     string asset path to a json
	 * @return  The `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 * 
	 * @see flixel.graphics.FlxAsepriteUtil.AseAtlasMeta
	 * @since 5.4.0
	 */
	public static inline function loadAseAtlas(sprite:FlxSprite, graphic, data:FlxAsepriteJsonAsset)
	{
		sprite.frames = FlxAtlasFrames.fromAseprite(graphic, data);
		return sprite;
	}
	
	/**
	 * Helper for parsing Aseprite atlas json files. Reads frame data via `loadAseAtlas`,
	 * then, adds animations for any tags listed, via `addAseAtlasTagsByPrefix`.
	 * 
	 * Notes: Assumes that the frame names are prefixed by tag name, assumes that the `tagSuffix`
	 * does not appear anywhere in the tag name and assumes that no tags overlap. You can use the
	 * filename format `{outertag}:{frame}` for most cases.
	 * 
	 * It's recommended to disable the "Ignore Empty" option if you have empty frames (that is, 
	 * empty on every layer), while it will reduce the size of your json, this method will
	 * not be able to add those empty frames to an animation
	 * 
	 * @param   sprite       The sprite to load the ase atlas's frames
	 * @param   graphic      The png file associated with the atlas
	 * @param   data         Can be an `AseAtlas` struct, a JSON string matching the `AseAtlas` or a
	 *                       string asset path to a json
	 * @param   tagSuffix    The delimeter on each frame name between the animation name and the
	 *                       frame number. Be sure to set your filename format to `{outertag}:{frame}`
	 * @param   excludeTags  A list of tags to ignore
	 * @return  The `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 * 
	 * @see flixel.graphics.FlxAsepriteUtil.AseAtlasMeta
	 * @since 5.4.0
	 */
	public static inline function loadAseAtlasAndTagsByPrefix(sprite, graphic, data:FlxAsepriteJsonAsset, tagSuffix = ":", ?excludeTags)
	{
		data = data.getData();
		loadAseAtlas(sprite, graphic, data);
		return addAseAtlasTagsByPrefix(sprite, data, tagSuffix, excludeTags);
	}
	
	/**
	 * Loops through the given ase atlas's tags and adds animations for each, to the given sprite.
	 * Uses the frame names to determine which tag they belong to.
	 * 
	 * Notes: Assumes that the frame names are prefixed by tag name, assumes that the `tagSuffix`
	 * does not appear anywhere in the tag name and assumes that no tags overlap. You can use the
	 * filename format `{outertag}:{frame}` for most cases.
	 * 
	 * It's recommended to disable the "Ignore Empty" option if you have empty frames (that is, 
	 * empty on every layer), while it will reduce the size of your json, this method will
	 * not be able to add those empty frames to an animation.
	 * 
	 * @param   sprite     The sprite to add the animations
	 * @param   data       Can be an `AseAtlas` struct, a JSON string matching the `AseAtlas` or a
	 *                     string asset path to a json
	 * @param   tagSuffix  The delimeter on each frame name between the animation name and the
	 *                     frame number. Be sure to set your filename format to `{outertag}:{frame}`
	 * @param   excludeTags  A list of tags to ignore
	 * @return  The `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 * 
	 * @see flixel.graphics.FlxAsepriteUtil.AseAtlasMeta
	 * @since 5.4.0
	 */
	public static inline function addAseAtlasTagsByPrefix(sprite:FlxSprite, data, tagSuffix = ":", ?excludeTags)
	{
		addByPrefixHelper(sprite.animation, data, tagSuffix, excludeTags);
		return sprite;
	}
	
	// TODO: overload addAseAtlasTagsByPrefix to take FlxAnimationController?
	// This might mess with codeclimate
	
	static function addByPrefixHelper(animations:FlxAnimationController, data:FlxAsepriteJsonAsset, tagSuffix = ":", excludeTags:Null<Array<String>>)
	{
		final aseData = data.getData();
		for (tag in aseData.meta.frameTags)
		{
			final name = tag.name;
			if (excludeTags == null || !excludeTags.contains(name))
			{
				final expectedFrames = tag.to - tag.from + 1;
				animations.addByPrefix(name, name + tagSuffix, 30, tag.repeat.loops);
				// Animations aren't added if no frames are found
				final anim = animations.getByName(name);
				setFramesDirection(anim.frames, tag.direction);
				final actualFrames = anim == null ? 0 : anim.numFrames;
				if (actualFrames != expectedFrames)
				{
					FlxG.log.warn('Tag "$name" expected $expectedFrames frames but found '
						+ '$actualFrames. Was the atlas exported with "Ignore Empty"/--ignore-empty'
						+ ', or are there multiple tags on a single frame?');
				}
			}
		}
	}
	
	/**
	 * Helper for parsing Aseprite atlas json files. Reads frame data via `loadAseAtlas`,
	 * then, adds animations for any tags listed, via `addAseAtlasTagsByIndex`.
	 * 
	 * Warning: It's important to disable the "Ignore Empty" option if you have empty frames (that
	 * is, empty on every layer) in tags, while it will reduce the size of your json, this method
	 * will not be able to add those empty frames to an animation.
	 * 
	 * @param   sprite       The sprite to load the ase atlas's frames
	 * @param   graphic      The png file associated with the atlas
	 * @param   data         Can be an `AseAtlas` struct, a JSON string matching the `AseAtlas` or a
	 *                       string asset path to a json
	 * @param   excludeTags  A list of tags to ignore
	 * @return  The `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 * 
	 * @see flixel.graphics.FlxAsepriteUtil.AseAtlasMeta
	 * @since 5.4.0
	 */
	public static inline function loadAseAtlasAndTagsByIndex(sprite:FlxSprite, graphic, data:FlxAsepriteJsonAsset, ?excludeTags)
	{
		data = data.getData();
		loadAseAtlas(sprite, graphic, data);
		return addAseAtlasTagsByIndex(sprite, data, excludeTags);
	}
	
	/**
	 * Loops through the given ase atlas's tags and adds animations for each, to the given sprite.
	 * Uses the tag's `to` and `from` fields to determine.
	 * 
	 * Warning: It's important to disable the "Ignore Empty" option if you have empty frames (that
	 * is, empty on every layer) in tags, while it will reduce the size of your json, this method
	 * will not be able to add those empty frames to an animation.
	 * 
	 * @param   sprite       The sprite to add the animations
	 * @param   data         Can be an `AseAtlas` struct, a JSON string matching the `AseAtlas` or a
	 *                       string asset path to a json
	 * @param   excludeTags  A list of tags to ignore
	 * @return  The `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 * 
	 * @see flixel.graphics.FlxAsepriteUtil.AseAtlasMeta
	 * @since 5.4.0
	 */
	public static inline function addAseAtlasTagsByIndex(sprite:FlxSprite, data:FlxAsepriteJsonAsset, ?excludeTags)
	{
		addByIndexHelper(sprite.animation, data, excludeTags);
		return sprite;
	}
	
	// TODO: overload addAseAtlasTagsByIndex to take FlxAnimationController?
	// This might mess with codeclimate
	
	static function addByIndexHelper(animations:FlxAnimationController, data:FlxAsepriteJsonAsset, excludeTags:Null<Array<String>>)
	{
		final aseData = data.getData();
		final maxFrameNumber = animations.numFrames - 1;
		for (frameTag in aseData.meta.frameTags)
		{
			if (frameTag.to > maxFrameNumber)
			{
				FlxG.log.warn('Tag "${frameTag.name}" `to` field (${frameTag.to}) exceeds the max '
					+ 'frame number ($maxFrameNumber). Some animations may not be loaded correctly. '
					+ 'Was the atlas exported with "Ignore Empty"/--ignore-empty?');
			}
			
			final toFrame = FlxMath.minInt(frameTag.to, maxFrameNumber);
			final frames = [for (i in frameTag.from...toFrame + 1) i];
			setFramesDirection(frames, frameTag.direction);
			// In Aseprite 0 or lower isn't a possible value, and toggling the "repeat" checkbox
			// toggles between "1" and infinity, which omits the field from json
			animations.add(frameTag.name, frames, 30, frameTag.repeat.loops);
		}
	}
	
	static function setFramesDirection(frames:Array<Int>, direction:AseAtlasTagDirection)
	{
		switch(direction)
		{
			case FORWARD:// do nothing
			case REVERSE:
				
				frames.reverse();
			case PINGPONG | PINGPONG_REVERSE:
				
				if (direction == PINGPONG_REVERSE)
					frames.reverse();
				
				var i = frames.length - 1;// skip last frame
				while (i-- > 1) // skip first frame too
					frames.push(frames[i]);
		}
	}
}
