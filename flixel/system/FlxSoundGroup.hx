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
	 * @param	volume  The intial volume of this group
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
			sound.group = this;
			sounds.push(sound);
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
	
	private function set_volume(volume:Float):Float
	{
		this.volume = volume;
		for (sound in sounds)
		{
			sound.updateTransform();
		}
		return volume;
	}
}