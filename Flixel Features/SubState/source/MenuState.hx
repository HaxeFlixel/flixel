package;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	// Link to the persistant substate (which will exist after closing)
	private var persistantSubState:SubState;
	
	private var openPersistantBtn:FlxButton;
	private var openTempBtn:FlxButton;
	private var sprites:MySpriteGroup;
	
	private var subStateColor:FlxColor;
	
	override public function create():Void
	{
		FlxG.cameras.bgColor = FlxColor.WHITE;
		
		destroySubStates = false;
		
		// Some test group of sprites, used for showing substate system features
		sprites = new MySpriteGroup(50);
		add(sprites);
		
		subStateColor = 0x99808080;
		
		// We can create persistant substate and use it as many times as we want
		persistantSubState = new SubState(subStateColor);
		persistantSubState.isPersistant = true;
	
		openPersistantBtn = new FlxButton(20, 20, "OpenPersistant", onPersistantClick);
		add(openPersistantBtn);
		
		openTempBtn = new FlxButton(20, 60, "OpenTemp", onTempClick);
		add(openTempBtn);
	}
	
	private function onTempClick():Void
	{
		// This is temp substate, it will be destroyed after closing
		var tempState:SubState = new SubState(subStateColor);
		tempState.isPersistant = false;
		openSubState(tempState);
	}
	
	private function onPersistantClick():Void
	{
		//FlxG.play("Beep");
		openSubState(persistantSubState);
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		sprites = null;
		
		// don't forget to destroy persistant substate
		persistantSubState.destroy();
		persistantSubState = null;
	}

	override public function update(elapsed:Float):Void
	{
		// We need to deactivate these buttons if there is _substate and this state is keeps updating
		//openPersistantBtn.active = (_subState == null);
		//openTempBtn.active = (_subState == null);
		
		super.update(elapsed);
	}	
}
