package;

import flixel.addons.util.FlxScene;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.ui.FlxButton;

// Make sure that classes that are only referenced via 
// xml are actually compiled by importing them
import entities.Monster;

class PlayState extends FlxState
{
	private var _scene:FlxScene;
	private var _specificMonster:Monster;

	// layers
	private var _hudGroup:FlxGroup;
	private var _monsterGroup:FlxGroup;

	override public function create():Void
	{
		super.create();

		createGroups();

		_scene = new FlxScene();
		_scene.set("assets/1.xml");

		// add all instances of specific layer to specified FlxGroup
		_scene.spawn(_hudGroup, "hud");
		_scene.spawn(_monsterGroup, "monsters");

		/* Alternatively:
		
		add all instances of all layers to specified FlxGroup:
		_scene.spawn(_myGroup);

		simply add all instances of all layers to stage:
		_scene.spawn();
		*/

		// References (by id)

		// <entity type="entities.Monster" id="specificMonster"  />
		_specificMonster = _scene.object("specificMonster");

		// <button id="reset_state" text="Reset State" alignBottom="10" alignRight="10" />
		var resetButton:FlxButton = _scene.object("reset_state");
		resetButton.onDown.callback = FlxG.resetState;

		// Constants (Int, Bool, Float, String)
		/*
		<const id="lives" type="Int" value="3" />
		<const id="precise" type="Float" value="60.2313" />
		<const id="raining" type="Bool" value="false" />
		<const id="boss_name" type="String" value="Hades" />
		*/

		var lives:Int = _scene.const("lives");
		var raining:Bool = _scene.const("raining");
		var precise:Float = _scene.const("precise");
		var boss_name:String = _scene.const("boss_name");

		trace("Constants: " + lives, raining, precise, boss_name);

		// ...
		FlxG.camera.antialiasing = true;
	}

	private function createGroups():Void
	{
		_monsterGroup = new FlxGroup();
		add(_monsterGroup);

		_hudGroup = new FlxGroup();
		add(_hudGroup);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		_specificMonster.x = FlxG.mouse.x;
		_specificMonster.y = FlxG.mouse.y;
	}
}