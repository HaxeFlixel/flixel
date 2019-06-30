package flixel.system;

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
	 * Create a new sound group
	 * @param	volume  The initial volume of this group
	 */
	public function new(volume:Float = 1)
	{
		this.volume = volume;
	}

	/**
	 * Add a sound to this group
	 * @param	sound The sound to add to this group
	 * @return True if sound was successfully added, false otherwise
	 */
	public function add(sound:FlxSound):Bool
	{
		if (sounds.indexOf(sound) < 0)
		{
			sounds.push(sound);
			sound.group = this;
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
		if (sounds.indexOf(sound) >= 0)
		{
			sound.group = null;
			return sounds.remove(sound);
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

	function set_volume(volume:Float):Float
	{
		this.volume = volume;
		for (sound in sounds)
		{
			sound.updateTransform();
		}
		return volume;
	}
}
