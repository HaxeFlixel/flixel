package flixel.sound;

import flixel.util.FlxStringUtil;

/**
 * A way of grouping sounds for things such as collective volume control
 */
class FlxSoundGroup extends FlxBasic
{
	/**
	 * The sounds in this group
	 */
	public var sounds:Array<FlxSound> = [];
	
	/**
	 * The volume of this group
	 */
	public var volume(default, set):Float;
	
	/**
	 * The pitch of this group
	 */
	public var pitch(default, set):Float;
	
	/**
	 * The position of this group in milliseconds.
	 * If set while paused, changes only come into effect after a `resume()` call.
	 */
	public var time(default, set):Float;
	
	/**
	 * The length of the *longest* sound in the group
	 */
	public var length(get, never):Float;
	
	/**
	 * Whether or not the sound group is currently playing.
	 */
	public var playing(default, null):Bool;
	
	/**
	 * Create a new sound group
	 * @param	volume  The initial volume of this group
	 */
	public function new(volume:Float = 1)
	{
		super();
		this.volume = volume;
		FlxG.signals.focusLost.add(onFocusLost);
		FlxG.signals.focusGained.add(onFocus);
	}
	
	override public function destroy()
	{
		for (sound in sounds)
			sound.destroy();
		super.destroy();
	}
	
	override public function kill():Void
	{
		super.kill();
		for (sound in sounds)
			@:privateAccess sound.cleanup(false);
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		for (sound in sounds)
			sound.update(elapsed);
	}
	
	/**
	 * Add a sound to this group, will remove the sound from any group it is currently in
	 * @param	sound The sound to add to this group
	 * @return True if sound was successfully added, false otherwise
	 */
	public function add(sound:FlxSound):Bool
	{
		if (!sounds.contains(sound))
		{
			// remove from prev group
			if (sound.group != null)
				sound.group.sounds.remove(sound);
				
			sounds.push(sound);
			@:bypassAccessor
			sound.group = this;
			sound.updateTransform();
			return true;
		}
		return false;
	}
	
	/**
	 * Remove a sound from this group
	 * @param	sound The sound to remove
	 * @return True if sound was successfully removed, false otherwise
	 */
	public function remove(sound:FlxSound):Bool
	{
		if (sounds.contains(sound))
		{
			@:bypassAccessor
			sound.group = null;
			sounds.remove(sound);
			sound.updateTransform();
			return true;
		}
		return false;
	}
	
	/**
	 * Call this function to pause all sounds in this group.
	 * @since 4.3.0
	 */
	public function pause():Void
	{
		for (sound in sounds)
			sound.pause();
		playing = false;
	}
	
	/**
	 * Call this function to pause all sounds in this group.
	 * @since 5.9.0
	 */
	public function play():Void
	{
		for (sound in sounds)
			sound.play();
		playing = true;
	}
	
	/**
	 * Call this function to pause all sounds in this group.
	 * @since 5.9.0
	 */
	public function stop():Void
	{
		for (sound in sounds)
			sound.stop();
		playing = false;
	}
	
	/**
	 * Unpauses all sounds in this group. Only works on sounds that have been paused.
	 * @since 4.3.0
	 */
	public function resume():Void
	{
		for (sound in sounds)
			sound.resume();
		playing = true;
	}
	
	function set_volume(volume:Float):Float
	{
		this.volume = volume;
		for (sound in sounds)
		{
			sound.volume = volume;
		}
		return volume;
	}
	
	function set_time(time:Float):Float
	{
		this.time = time;
		for (sound in sounds)
		{
			sound.time = time;
		}
		return time;
	}
	
	function set_pitch(pitch:Float):Float
	{
		this.pitch = pitch;
		for (sound in sounds)
		{
			sound.pitch = pitch;
		}
		return pitch;
	}
	
	function get_time():Float
	{
		return time;
	}
	
	function get_length():Float
	{
		var _length:Float = 0.0;
		for (sound in sounds)
		{
			if (sound.length > _length)
			{
				_length = sound.length;
			}
		}
		return _length;
	}
	
	var _alreadyPaused:Bool = false;
	var _paused:Bool;
	
	function onFocus():Void
	{
		for(sound in sounds)
			@:privateAccess sound.onFocus();
	}
	
	function onFocusLost():Void
	{
		for(sound in sounds)
			@:privateAccess sound.onFocusLost();
	}
	
	override public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("playing", playing),
			LabelValuePair.weak("time", time),
			LabelValuePair.weak("length", length),
			LabelValuePair.weak("volume", volume)
		]);
	}
}
