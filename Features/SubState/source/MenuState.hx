package;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	// Link to the persistent substate (which will exist after closing)
	var persistentSubState:SubState;
	
	var openpersistentBtn:FlxButton;
	var openTempBtn:FlxButton;
	var sprites:MySpriteGroup;
	
	var subStateColor:FlxColor;
	
	override public function create():Void
	{
		FlxG.cameras.bgColor = FlxColor.WHITE;
		
		destroySubStates = false;
		
		// Some test group of sprites, used for showing substate system features
		sprites = new MySpriteGroup(50);
		add(sprites);
		
		subStateColor = 0x99808080;
		
		// We can create persistent substate and use it as many times as we want
		persistentSubState = new SubState(subStateColor);
		persistentSubState.isPersistent = true;
	
		openpersistentBtn = new FlxButton(20, 20, "OpenPersistent", onpersistentClick);
		add(openpersistentBtn);
		
		openTempBtn = new FlxButton(20, 60, "OpenTemp", onTempClick);
		add(openTempBtn);
	}
	
	function onTempClick():Void
	{
		// This is temp substate, it will be destroyed after closing
		var tempState:SubState = new SubState(subStateColor);
		tempState.isPersistent = false;
		openSubState(tempState);
	}
	
	function onpersistentClick():Void
	{
		openSubState(persistentSubState);
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		sprites = null;
		
		// don't forget to destroy persistent substate
		persistentSubState.destroy();
		persistentSubState = null;
	}

	override public function update(elapsed:Float):Void
	{
		// We need to deactivate these buttons if there is _substate and this state is keeps updating
		//openpersistentBtn.active = (_subState == null);
		//openTempBtn.active = (_subState == null);
		
		super.update(elapsed);
	}
}
