package flixel.group;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxContainer;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxDestroyUtil;

/**
 * `FlxSpriteContainer` is a special `FlxSprite` that can be treated like a single sprite even
 * if it's made up of several member sprites. It shares the `FlxGroup` API, but it doesn't inherit
 * from it. Note that `FlxSpriteContainer` is a `FlxSpriteGroup` but the group is a `FlxContainer`.
 * 
 * ## When to use a group or container
 * `FlxGroups` are better for organising arbitrary groups for things like iterating or collision.
 * `FlxContainers` are recommended when you are adding them to the current `FlxState`, or a
 * child (or grandchild, and so on) of the state.
 * Since `FlxSpriteGroups` and `FlxSpriteContainers` are usually meant to draw groups of sprites
 * rather than organizing them for collision or iterating, it's recommended to always use
 * `FlxSpriteContainer` instead of `FlxSpriteGroup`.
 * @since 5.7.0
 */
typedef FlxSpriteContainer = FlxTypedSpriteContainer<FlxSprite>;

/**
 * A `FlxSpriteContainer` that only allows specific members to be a specific type of `FlxSprite`.
 * To use any kind of `FlxSprite` use `FlxSpriteContainer`, which is an alias for
 * `FlxTypedSpriteContainer<FlxSprite>`.
 * @since 5.7.0
 */
class FlxTypedSpriteContainer<T:FlxSprite> extends FlxTypedSpriteGroup<T>
{
	override function initGroup(maxSize):Void
	{
		@:bypassAccessor
		group = new SpriteContainer<T>(this, maxSize);
	}
	
	@:access(flixel.FlxCamera)
	override function draw():Void
	{
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (_cameras != null)
		{
			FlxCamera._defaultCameras = _cameras;
		}
		
		super.draw();
		
		FlxCamera._defaultCameras = oldDefaultCameras;
	}
	
	@:deprecated("FlxSpriteContainer.group can not be set")
	override function set_group(value:FlxTypedGroup<T>):FlxTypedGroup<T>
	{
		throw "FlxSpriteContainer.group cannot be set in FlxSpriteContainers";
	}
	
	override function set_camera(value:FlxCamera):FlxCamera
	{
		// Do not set children's cameras, this in no longer needed
		_cameras = value == null ? null : [value];
		return value;
	}
	
	override function set_cameras(value:Array<FlxCamera>):Array<FlxCamera>
	{
		// Do not set children's cameras, this in no longer needed
		return _cameras = value;
	}
}

/**
 * A special `FlxContainer` that shares mirrors the container information of it's
 * containing sprite.
 */
@:dox(hide)
private class SpriteContainer<T:FlxSprite> extends FlxTypedContainer<T>
{
	var parentSprite:FlxTypedSpriteContainer<T>;
	
	public function new (parent:FlxTypedSpriteContainer<T>, maxSize:Int)
	{
		parentSprite = parent;
		super(maxSize);
	}
	
	override function get_container()
	{
		return parentSprite.container;
	}
	
	override function getCamerasLegacy()
	{
		return (_cameras != null ? _cameras : parentSprite.getCamerasLegacy());
	}
	
	override function getCameras()
	{
		return (_cameras != null ? _cameras : parentSprite.getCameras());
	}
}
