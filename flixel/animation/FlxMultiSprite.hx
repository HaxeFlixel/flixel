package flixel.animation;

import flixel.group.FlxTypedGroup;
import flixel.util.FlxPoint;
import flixel.animation.FlxAnimationController;


/**
 * A FlxSprite alternative, which can load animations from different spritesheets,
 * with one restriction, one animation must be interely contained in one spritesheet
 * It is designed to be used with <code>loadImageFromTexture()</code> it shows where
 * animations must be loaded from.
 * For example:
 * <code>
 *     sprite.loadImagesFromTexture(spritesheet1,...);
 *     sprite.animation.addByIndicies('cast', 'cast', [1, 2, 3], ".png", 10, false);
 *     sprite.animation.addByIndicies('cast_fire', 'cast_fire', [1, 2, 3], ".png", 10, false);
 *
 *     sprite.loadImagesFromTexture(spritesheet2,...);
 *     sprite.animation.addByIndicies('walk', 'walk', [1, 2, 3], ".png", 10, false);
 *     sprite.animation.addByIndicies('run', 'run', [1, 2, 3], ".png", 10, false);
 * </code>
 * Here we load casts from spritesheet1 and run and walk from spritesheet2
 **/
class FlxMultiSprite extends FlxSprite {

	public var group:FlxTypedGroup<FlxSprite>;
	public var multiAnimation:MultiAnimationController; //same object as the animation, used here to avoid casts in the code;
	/**
	 * @param	X				The initial X position of the sprite.
	 * @param	Y				The initial Y position of the sprite.
	 */
	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
		moves  = true;
		group = new FlxTypedGroup<FlxSprite>();
	}

	override public function update():Void
	{
		super.update();
		group.update();
	}

	override public function draw():Void
	{
		group.draw();
	}


	override private function initVars():Void
	{
		super.initVars();
		multiAnimation = new MultiAnimationController(this);
		animation = multiAnimation;
	}
	/**
	 * Loads TexturePacker atlas, each load creates one internal sprite
	 * @param	Data		Atlas data holding links to json-data and atlas image
	 * @param	Reverse		Whether you need this class to generate horizontally flipped versions of the animation frames.
	 * @param	Unique		Optional, whether the graphic should be a unique instance in the graphics cache.  Default is false.
	 * @param	FrameName	Default frame to show. If null then will be used first available frame.
	 * @return This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	override public function loadImageFromTexture(Data:Dynamic, Reverse:Bool = false, Unique:Bool = false, ?FrameName:String):FlxSprite {
		multiAnimation.currentSprite = new FlxSprite(x, y);
		multiAnimation.currentSprite.loadImageFromTexture(Data, Reverse, Unique, FrameName);
		group.add(multiAnimation.currentSprite);
		return this;
	}
	private function allSprites():Array<FlxSprite> {
		return if (group!=null) {
			group.members;
		} else {
			[];
		}
	}
	public function hideAllSprites() {
		for (sprite in allSprites()) {
			sprite.visible = false;
		}
	}
	override private function set_scale(Value:FlxPoint):FlxPoint
	{
		for (sprite in allSprites()) {
			sprite.scale = Value;
		}
		return super.set_scale(Value);
	}

	override private function set_facing(Direction:Int):Int {
		for (sprite in allSprites()) {
			sprite.facing = Direction;
		}
		return super.set_facing(Direction);
	}
	override private function set_color(Color:Int):Int
	{
		for (sprite in allSprites()) {
			sprite.color = Color;
		}
		return super.set_color(Color);
	}

	override private function set_visible(Value:Bool):Bool
	{
		if(exists && visible != Value)
			for (sprite in allSprites()) {
				sprite.visible = Value;
			}
		return super.set_visible(Value);
	}

	override private function set_active(Value:Bool):Bool
	{
		if(exists && active != Value)
			for (sprite in allSprites()) {
				sprite.active = Value;
			}
		return super.set_active(Value);
	}

	override private function set_alive(Value:Bool):Bool
	{
		if(exists && alive != Value)
			for (sprite in allSprites()) {
				sprite.alive = Value;
			}
		return super.set_alive(Value);
	}

	override private function set_x(NewX:Float):Float
	{
		if (x != NewX) {
			for (sprite in allSprites()) {
				sprite.x = NewX;
			}
		}

		return x = NewX;
	}

	override private function set_y(NewY:Float):Float
	{
		if (y != NewY) {
			for (sprite in allSprites()) {
				sprite.y = NewY;
			}
		}

		return y = NewY;
	}
}
/**
 * This is helping class which manages animations for FlxMultiSprite
 **/
class MultiAnimationController extends FlxAnimationController {
	private var animationsMap:Map<String, FlxSprite>;
	public var currentSprite:FlxSprite;
	private var parent:FlxMultiSprite;  //doubling variable _sprite:FlxSprite to avoid casting,
										// if cast speed will improve for all platform this can be removed
	private var currentAnimationName:String = null;

	public function new(Sprite:FlxMultiSprite) {
		super(Sprite);
		parent = Sprite;
		animationsMap = new Map<String, FlxSprite>();
	}


	/**
	 * Adds a new _animations to the sprite.
	 * @param	Name			What this _animations should be called (e.g. "run").
	 * @param	FrameNames		An array of image names from atlas indicating what frames to play in what order.
	 * @param	FrameRate		The speed in frames per second that the _animations should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the _animations is looped or just plays once.
	 */
	override public function addByNames(Name:String, FrameNames:Array<String>, FrameRate:Int = 30, Looped:Bool = true):Void
	{
		currentSprite.animation.addByNames(Name, FrameNames, FrameRate, Looped);
		animationsMap[Name] = currentSprite;
	}
	/**
	 * Adds a new _animations to the sprite.
	 * @param	Name			What this _animations should be called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	 * @param	Indicies		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
	 * @param	Postfix			Common ending of image names in atlas (e.g. ".png")
	 * @param	FrameRate		The speed in frames per second that the _animations should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the _animations is looped or just plays once.
	 */
	override public function addByIndicies(Name:String, Prefix:String, Indicies:Array<Int>, Postfix:String, FrameRate:Int = 30, Looped:Bool = true):Void
	{
		currentSprite.animation.addByIndicies(Name, Prefix, Indicies, Postfix, FrameRate, Looped);
		animationsMap[Name] = currentSprite;
	}

	/**
	 * Adds a new _animations to the sprite.
	 * @param	Name			What this _animations should be called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	 * @param	FrameRate		The speed in frames per second that the _animations should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the _animations is looped or just plays once.
	*/
	override public function addByPrefix(Name:String, Prefix:String, FrameRate:Int = 30, Looped:Bool = true):Void {
		currentSprite.animation.addByPrefix(Name, Prefix, FrameRate, Looped);
		animationsMap[Name] = currentSprite;
	}
	/**
	 * Plays an existing _animations (e.g. "run").
	 * If you call an _animations that is already playing it will be ignored.
	 * @param	AnimName	The string name of the _animations you want to play.
	 * @param	Force		Whether to force the _animations to restart.
	 * @param	Frame		The frame number in _animations you want to start from (0 by default). If you pass negative value then it will start from random frame
	 */
	override public function play(AnimName:String, Force:Bool = false, Frame:Int = 0):Void {
		parent.hideAllSprites();
		currentSprite = animationsMap[AnimName];
		if (currentSprite == null) {
			trace('ERROR! The currentSprite is null for animation $AnimName'); //added trace, because throw is not working, when it will be fixed - it can be removed
			throw 'Unable to find animation $AnimName';
		}
		this.currentAnimationName = AnimName;
		currentSprite.visible = true;
		currentSprite.animation.play(AnimName, Force, Frame);
	}
	/**
	 * Gets the name of the currently playing _animations (warning: can be null)
	 */
	override private function get_name():String
	{
		return currentAnimationName;
	}
	override private function get_finished():Bool {
		return currentSprite.animation.finished;
	}
}
