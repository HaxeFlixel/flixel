package;

import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;

/**
 * ...
 * @author Zaphod
 */
class SubState extends FlxSubState
{
	// Some test sprite, showing that if the state is persistent (not destroyed after closing)
	// then it will save it's position (and all other properties)
	var testSprite:FlxSprite;

	var closeBtn:FlxButton;
	var switchParentDrawingBtn:FlxButton;
	var switchParentUpdatingBtn:FlxButton;

	// just a helper flag, showing if this substate is persistent or not
	public var isPersistent:Bool = false;

	override public function create():Void
	{
		super.create();

		closeBtn = new FlxButton(FlxG.width * 0.5 - 40, FlxG.height * 0.5, "Close", onClick);
		add(closeBtn);

		switchParentDrawingBtn = new FlxButton(closeBtn.x, closeBtn.y + 40, "SwitchDraw", onSwitchDraw);
		add(switchParentDrawingBtn);

		switchParentUpdatingBtn = new FlxButton(switchParentDrawingBtn.x, switchParentDrawingBtn.y + 40, "SwitchUpdate", onSwitchUpdate);
		add(switchParentUpdatingBtn);

		testSprite = new FlxSprite(0, 10);
		testSprite.velocity.x = 20;
		add(testSprite);
	}

	function onSwitchUpdate()
	{
		if (_parentState != null)
		{
			// you can keep updating parent state if you want to, but keep in mind that
			// if you will update parent state then you will update buttons in it,
			// so you need to deactivate buttons in parent state
			_parentState.persistentUpdate = !_parentState.persistentUpdate;
		}
	}

	function onSwitchDraw()
	{
		if (_parentState != null)
		{
			// you can keep drawing parent state if you want to
			// (for example, when substate have transparent background color)
			_parentState.persistentDraw = !_parentState.persistentDraw;
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (testSprite.x > FlxG.width)
		{
			testSprite.x = -testSprite.width;
		}
	}

	function onClick()
	{
		// if you will pass 'true' (which is by default) into close() method then this substate will be destroyed
		// but when you'll pass 'false' then you should destroy it manually
		close();
	}

	// This function will be called by substate right after substate will be closed
	public static function onSubstateClose():Void
	{
		// FlxG.fade(FlxG.BLACK, 1, true);
	}
}
