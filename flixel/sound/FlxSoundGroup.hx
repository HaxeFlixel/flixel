package flixel.sound;

/**
 * A way of grouping sounds for things such as collective volume control
 */
class FlxSoundGroup
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
	 * Whether or not this group is muted
	 */
	public var muted(default, set):Bool;

	/**
	 * Create a new sound group
	 * @param	volume  The initial volume of this group
	 */
	public function new(volume:Float = 1)
	{
		this.volume = volume;
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
	}

	/**
	 * Unpauses all sounds in this group. Only works on sounds that have been paused.
	 * @since 4.3.0
	 */
	public function resume():Void
	{
		for (sound in sounds)
			sound.resume();
	}

	/**
	 * Returns the volume of this group, taking `muted` in account.
	 * @return The volume of the group or 0 if the group is muted.
	 */
	public function getVolume():Float
	{
		return muted ? 0.0 : volume;
	}

	function set_volume(volume:Float):Float
	{
		this.volume = volume;
		for (sound in sounds)
		{
			sound.updateTransform();
		}
		return volume;
	}

	function set_muted(value:Bool):Bool
	{
		muted = value;
		for (sound in sounds)
		{
			sound.updateTransform();
		}
		return muted;
	}
}
