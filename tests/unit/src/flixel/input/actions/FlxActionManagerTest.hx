package flixel.input.actions;

#if FLX_GAMEINPUT_API
import openfl.ui.GameInput;
import openfl.ui.GameInputDevice;
import openfl.ui.GameInputControl;
import lime.ui.Gamepad;
#elseif FLX_JOYSTICK_API
import openfl.events.JoystickEvent;
#end
import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionInputAnalog.FlxActionInputAnalogMouseMotion;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalKeyboard;
import flixel.input.gamepad.FlxGamepad.FlxGamepadModel;
import flixel.input.keyboard.FlxKey;
import haxe.Json;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;
#if FLX_STEAMWRAP
import steamwrap.data.ControllerConfig;
#end
import massive.munit.Assert;

class FlxActionManagerTest extends FlxTest
{
	#if FLX_STEAMWRAP
	var steamManager:FlxActionManager;
	#end

	var basicManager:FlxActionManager;
	var sets:Array<String>;
	var analog:Array<Array<String>>;
	var digital:Array<Array<String>>;

	var valueTest = "";
	var connectStr:String = "";
	var disconnectStr:String = "";

	@Before
	function before()
	{
		createFlxActionManager();
		sets = ["MenuControls", "MapControls", "BattleControls"];
		analog = [["menu_move"], ["scroll_map", "move_map"], ["move"]];
		digital = [
			[
				"menu_up", "menu_down", "menu_left", "menu_right", "menu_select", "menu_menu", "menu_cancel", "menu_thing_1", "menu_thing_2", "menu_thing_3"
			],
			["map_select", "map_exit", "map_menu", "map_journal"],
			["punch", "kick", "jump"]
		];
	}

	@Test
	function testInit()
	{
		Assert.isTrue(basicManager.numSets == 3);

		var t = new TestShell("init.");

		runFlxActionManagerInit(t);

		t.assertTrue("init.MenuControls.indexExists");
		t.assertTrue("init.MenuControls.nameMatches");
		t.assertTrue("init.MenuControls.setExists");

		t.assertTrue("init.MapControls.indexExists");
		t.assertTrue("init.MapControls.nameMatches");
		t.assertTrue("init.MapControls.setExists");

		t.assertTrue("init.BattleControls.indexExists");
		t.assertTrue("init.BattleControls.nameMatches");
		t.assertTrue("init.BattleControls.setExists");

		t.destroy();
	}

	#if FLX_STEAMWRAP
	@Test
	function testInitSteam()
	{
		Assert.isTrue(steamManager.numSets == 3);

		var t = new TestShell("steam.init.");

		runFlxActionManagerInit(t, steamManager);

		t.assertTrue("steam.init.MenuControls.indexExists");
		t.assertTrue("steam.init.MenuControls.nameMatches");
		t.assertTrue("steam.init.MenuControls.setExists");

		t.assertTrue("steam.init.MapControls.indexExists");
		t.assertTrue("steam.init.MapControls.nameMatches");
		t.assertTrue("steam.init.MapControls.setExists");

		t.assertTrue("steam.init.BattleControls.indexExists");
		t.assertTrue("steam.init.BattleControls.nameMatches");
		t.assertTrue("steam.init.BattleControls.setExists");

		t.destroy();
	}
	#end

	@Test
	function testActions()
	{
		var t = new TestShell("actions.");

		runFlxActionManagerActions(t);

		t.assertTrue("actions.MenuControls.hasDigital");
		t.assertTrue("actions.MenuControls.hasAnalog");
		t.assertTrue("actions.MenuControls.digital.menu_up.exists");
		t.assertTrue("actions.MenuControls.digital.menu_down.exists");
		t.assertTrue("actions.MenuControls.digital.menu_left.exists");
		t.assertTrue("actions.MenuControls.digital.menu_right.exists");
		t.assertTrue("actions.MenuControls.digital.menu_select.exists");
		t.assertTrue("actions.MenuControls.digital.menu_menu.exists");
		t.assertTrue("actions.MenuControls.digital.menu_cancel.exists");
		t.assertTrue("actions.MenuControls.digital.menu_thing_1.exists");
		t.assertTrue("actions.MenuControls.digital.menu_thing_2.exists");
		t.assertTrue("actions.MenuControls.digital.menu_thing_3.exists");
		t.assertTrue("actions.MenuControls.analog.menu_move.exists");

		t.assertTrue("actions.MapControls.hasDigital");
		t.assertTrue("actions.MapControls.hasAnalog");
		t.assertTrue("actions.MapControls.digital.map_select.exists");
		t.assertTrue("actions.MapControls.digital.map_exit.exists");
		t.assertTrue("actions.MapControls.digital.map_menu.exists");
		t.assertTrue("actions.MapControls.digital.map_journal.exists");
		t.assertTrue("actions.MapControls.analog.scroll_map.exists");
		t.assertTrue("actions.MapControls.analog.move_map.exists");

		t.assertTrue("actions.BattleControls.hasDigital");
		t.assertTrue("actions.BattleControls.hasAnalog");
		t.assertTrue("actions.BattleControls.digital.punch.exists");
		t.assertTrue("actions.BattleControls.digital.kick.exists");
		t.assertTrue("actions.BattleControls.digital.jump.exists");
		t.assertTrue("actions.BattleControls.analog.move.exists");

		t.destroy();
	}

	#if FLX_STEAMWRAP
	@Test
	function testActionsSteam()
	{
		var t = new TestShell("steam.actions.");

		runFlxActionManagerActions(t, steamManager);

		t.assertTrue("steam.actions.MenuControls.hasDigital");
		t.assertTrue("steam.actions.MenuControls.hasAnalog");
		t.assertTrue("steam.actions.MenuControls.digital.menu_up.exists");
		t.assertTrue("steam.actions.MenuControls.digital.menu_down.exists");
		t.assertTrue("steam.actions.MenuControls.digital.menu_left.exists");
		t.assertTrue("steam.actions.MenuControls.digital.menu_right.exists");
		t.assertTrue("steam.actions.MenuControls.digital.menu_select.exists");
		t.assertTrue("steam.actions.MenuControls.digital.menu_menu.exists");
		t.assertTrue("steam.actions.MenuControls.digital.menu_cancel.exists");
		t.assertTrue("steam.actions.MenuControls.digital.menu_thing_1.exists");
		t.assertTrue("steam.actions.MenuControls.digital.menu_thing_2.exists");
		t.assertTrue("steam.actions.MenuControls.digital.menu_thing_3.exists");
		t.assertTrue("steam.actions.MenuControls.analog.menu_move.exists");

		t.assertTrue("steam.actions.MapControls.hasDigital");
		t.assertTrue("steam.actions.MapControls.hasAnalog");
		t.assertTrue("steam.actions.MapControls.digital.map_select.exists");
		t.assertTrue("steam.actions.MapControls.digital.map_exit.exists");
		t.assertTrue("steam.actions.MapControls.digital.map_menu.exists");
		t.assertTrue("steam.actions.MapControls.digital.map_journal.exists");
		t.assertTrue("steam.actions.MapControls.analog.scroll_map.exists");
		t.assertTrue("steam.actions.MapControls.analog.move_map.exists");

		t.assertTrue("steam.actions.BattleControls.hasDigital");
		t.assertTrue("steam.actions.BattleControls.hasAnalog");
		t.assertTrue("steam.actions.BattleControls.digital.punch.exists");
		t.assertTrue("steam.actions.BattleControls.digital.kick.exists");
		t.assertTrue("steam.actions.BattleControls.digital.jump.exists");
		t.assertTrue("steam.actions.BattleControls.analog.move.exists");

		t.destroy();
	}
	#end

	@Test
	function testAddRemove()
	{
		var t = new TestShell("addRemove.");

		runFlxActionManagerAddRemove(t);

		t.assertTrue("addRemove.MenuControls.digital.extra.add");
		t.assertTrue("addRemove.MenuControls.digital.extra.remove");
		t.assertTrue("addRemove.MenuControls.analog.extra.add");
		t.assertTrue("addRemove.MenuControls.analog.extra.remove");

		t.assertTrue("addRemove.MapControls.digital.extra.add");
		t.assertTrue("addRemove.MapControls.digital.extra.remove");
		t.assertTrue("addRemove.MapControls.analog.extra.add");
		t.assertTrue("addRemove.MapControls.analog.extra.remove");

		t.assertTrue("addRemove.BattleControls.digital.extra.add");
		t.assertTrue("addRemove.BattleControls.digital.extra.remove");
		t.assertTrue("addRemove.BattleControls.analog.extra.add");
		t.assertTrue("addRemove.BattleControls.analog.extra.remove");

		t.destroy();
	}

	@Test
	function testMouse()
	{
		var t = new TestShell("device.");

		runFlxActionManagerDevice(MOUSE, t);

		t.assertTrue("device.MenuControls.activatedFor.MOUSE");
		t.assertTrue("device.MenuControls.notActivatedFor.KEYBOARD.but.MOUSE");
		t.assertTrue("device.MenuControls.notActivatedFor.GAMEPAD.but.MOUSE");
		t.assertTrue("device.MenuControls.deactivatedFor.MOUSE");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.KEYBOARD.but.MOUSE");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.GAMEPAD.but.MOUSE");

		t.assertTrue("device.MapControls.activatedFor.MOUSE");
		t.assertTrue("device.MapControls.notActivatedFor.KEYBOARD.but.MOUSE");
		t.assertTrue("device.MapControls.notActivatedFor.GAMEPAD.but.MOUSE");
		t.assertTrue("device.MapControls.deactivatedFor.MOUSE");
		t.assertTrue("device.MapControls.stillNotActivatedFor.KEYBOARD.but.MOUSE");
		t.assertTrue("device.MapControls.stillNotActivatedFor.GAMEPAD.but.MOUSE");

		t.assertTrue("device.BattleControls.activatedFor.MOUSE");
		t.assertTrue("device.BattleControls.notActivatedFor.KEYBOARD.but.MOUSE");
		t.assertTrue("device.BattleControls.notActivatedFor.GAMEPAD.but.MOUSE");
		t.assertTrue("device.BattleControls.deactivatedFor.MOUSE");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.KEYBOARD.but.MOUSE");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.GAMEPAD.but.MOUSE");

		#if FLX_STEAMWRAP
		t.assertTrue("device.MenuControls.notActivatedFor.STEAM_CONTROLLER.but.MOUSE");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.STEAM_CONTROLLER.but.MOUSE");
		t.assertTrue("device.MapControls.notActivatedFor.STEAM_CONTROLLER.but.MOUSE");
		t.assertTrue("device.MapControls.stillNotActivatedFor.STEAM_CONTROLLER.but.MOUSE");
		t.assertTrue("device.BattleControls.notActivatedFor.STEAM_CONTROLLER.but.MOUSE");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.STEAM_CONTROLLER.but.MOUSE");
		#end

		t.destroy();
	}

	@Test
	function testKeyboard()
	{
		var t = new TestShell("device.");

		runFlxActionManagerDevice(KEYBOARD, t);

		t.assertTrue("device.MenuControls.activatedFor.KEYBOARD");
		t.assertTrue("device.MenuControls.notActivatedFor.MOUSE.but.KEYBOARD");
		t.assertTrue("device.MenuControls.notActivatedFor.GAMEPAD.but.KEYBOARD");
		t.assertTrue("device.MenuControls.deactivatedFor.KEYBOARD");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.MOUSE.but.KEYBOARD");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.GAMEPAD.but.KEYBOARD");

		t.assertTrue("device.MapControls.activatedFor.KEYBOARD");
		t.assertTrue("device.MapControls.notActivatedFor.MOUSE.but.KEYBOARD");
		t.assertTrue("device.MapControls.notActivatedFor.GAMEPAD.but.KEYBOARD");
		t.assertTrue("device.MapControls.deactivatedFor.KEYBOARD");
		t.assertTrue("device.MapControls.stillNotActivatedFor.MOUSE.but.KEYBOARD");
		t.assertTrue("device.MapControls.stillNotActivatedFor.GAMEPAD.but.KEYBOARD");

		t.assertTrue("device.BattleControls.activatedFor.KEYBOARD");
		t.assertTrue("device.BattleControls.notActivatedFor.MOUSE.but.KEYBOARD");
		t.assertTrue("device.BattleControls.notActivatedFor.GAMEPAD.but.KEYBOARD");
		t.assertTrue("device.BattleControls.deactivatedFor.KEYBOARD");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.MOUSE.but.KEYBOARD");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.GAMEPAD.but.KEYBOARD");

		#if FLX_STEAMWRAP
		t.assertTrue("device.MenuControls.notActivatedFor.STEAM_CONTROLLER.but.KEYBOARD");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.STEAM_CONTROLLER.but.KEYBOARD");
		t.assertTrue("device.MapControls.notActivatedFor.STEAM_CONTROLLER.but.KEYBOARD");
		t.assertTrue("device.MapControls.stillNotActivatedFor.STEAM_CONTROLLER.but.KEYBOARD");
		t.assertTrue("device.BattleControls.notActivatedFor.STEAM_CONTROLLER.but.KEYBOARD");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.STEAM_CONTROLLER.but.KEYBOARD");
		#end

		t.destroy();
	}

	@Test
	function testGamepad()
	{
		#if flash
		return;
		#end

		var t = new TestShell("device.");

		runFlxActionManagerDevice(GAMEPAD, t);

		t.assertTrue("device.MenuControls.activatedFor.GAMEPAD");
		t.assertTrue("device.MenuControls.notActivatedFor.MOUSE.but.GAMEPAD");
		t.assertTrue("device.MenuControls.notActivatedFor.KEYBOARD.but.GAMEPAD");
		t.assertTrue("device.MenuControls.deactivatedFor.GAMEPAD");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.MOUSE.but.GAMEPAD");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.KEYBOARD.but.GAMEPAD");

		t.assertTrue("device.MapControls.activatedFor.GAMEPAD");
		t.assertTrue("device.MapControls.notActivatedFor.MOUSE.but.GAMEPAD");
		t.assertTrue("device.MapControls.notActivatedFor.KEYBOARD.but.GAMEPAD");
		t.assertTrue("device.MapControls.deactivatedFor.GAMEPAD");
		t.assertTrue("device.MapControls.stillNotActivatedFor.MOUSE.but.GAMEPAD");
		t.assertTrue("device.MapControls.stillNotActivatedFor.KEYBOARD.but.GAMEPAD");

		t.assertTrue("device.BattleControls.activatedFor.GAMEPAD");
		t.assertTrue("device.BattleControls.notActivatedFor.MOUSE.but.GAMEPAD");
		t.assertTrue("device.BattleControls.notActivatedFor.KEYBOARD.but.GAMEPAD");
		t.assertTrue("device.BattleControls.deactivatedFor.GAMEPAD");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.MOUSE.but.GAMEPAD");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.KEYBOARD.but.GAMEPAD");

		#if FLX_STEAMWRAP
		t.assertTrue("device.MenuControls.notActivatedFor.STEAM_CONTROLLER.but.GAMEPAD");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.STEAM_CONTROLLER.but.GAMEPAD");
		t.assertTrue("device.MapControls.notActivatedFor.STEAM_CONTROLLER.but.GAMEPAD");
		t.assertTrue("device.MapControls.stillNotActivatedFor.STEAM_CONTROLLER.but.GAMEPAD");
		t.assertTrue("device.BattleControls.notActivatedFor.STEAM_CONTROLLER.but.GAMEPAD");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.STEAM_CONTROLLER.but.GAMEPAD");
		#end

		t.destroy();
	}

	#if FLX_STEAMWRAP
	@Test
	function testSteamController()
	{
		var t = new TestShell("device.");

		runFlxActionManagerDevice(STEAM_CONTROLLER, t);

		t.assertTrue("device.MenuControls.activatedFor.STEAM_CONTROLLER");
		t.assertTrue("device.MenuControls.notActivatedFor.MOUSE.but.STEAM_CONTROLLER");
		t.assertTrue("device.MenuControls.notActivatedFor.KEYBOARD.but.STEAM_CONTROLLER");
		t.assertTrue("device.MenuControls.notActivatedFor.GAMEPAD.but.STEAM_CONTROLLER");
		t.assertTrue("device.MenuControls.deactivatedFor.STEAM_CONTROLLER");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.MOUSE.but.STEAM_CONTROLLER");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.KEYBOARD.but.STEAM_CONTROLLER");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.GAMEPAD.but.STEAM_CONTROLLER");

		t.assertTrue("device.MapControls.activatedFor.STEAM_CONTROLLER");
		t.assertTrue("device.MapControls.notActivatedFor.MOUSE.but.STEAM_CONTROLLER");
		t.assertTrue("device.MapControls.notActivatedFor.KEYBOARD.but.STEAM_CONTROLLER");
		t.assertTrue("device.MapControls.notActivatedFor.GAMEPAD.but.STEAM_CONTROLLER");
		t.assertTrue("device.MapControls.deactivatedFor.STEAM_CONTROLLER");
		t.assertTrue("device.MapControls.stillNotActivatedFor.MOUSE.but.STEAM_CONTROLLER");
		t.assertTrue("device.MapControls.stillNotActivatedFor.KEYBOARD.but.STEAM_CONTROLLER");
		t.assertTrue("device.MapControls.stillNotActivatedFor.GAMEPAD.but.STEAM_CONTROLLER");

		t.assertTrue("device.BattleControls.activatedFor.STEAM_CONTROLLER");
		t.assertTrue("device.BattleControls.notActivatedFor.MOUSE.but.STEAM_CONTROLLER");
		t.assertTrue("device.BattleControls.notActivatedFor.KEYBOARD.but.STEAM_CONTROLLER");
		t.assertTrue("device.BattleControls.notActivatedFor.GAMEPAD.but.STEAM_CONTROLLER");
		t.assertTrue("device.BattleControls.deactivatedFor.STEAM_CONTROLLER");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.MOUSE.but.STEAM_CONTROLLER");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.KEYBOARD.but.STEAM_CONTROLLER");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.GAMEPAD.but.STEAM_CONTROLLER");

		t.destroy();
	}
	#end

	@Test
	function testAllDevices()
	{
		var t = new TestShell("device.");

		runFlxActionManagerDevice(ALL, t);

		t.assertTrue("device.MenuControls.activatedFor.ALL");
		t.assertTrue("device.MenuControls.activatedForAll.MOUSE");
		t.assertTrue("device.MenuControls.activatedForAll.KEYBOARD");
		t.assertTrue("device.MenuControls.activatedForAll.GAMEPAD");
		t.assertTrue("device.MenuControls.deactivatedFor.ALL");
		t.assertTrue("device.MenuControls.deactivatedForAll.MOUSE");
		t.assertTrue("device.MenuControls.deactivatedForAll.KEYBOARD");
		t.assertTrue("device.MenuControls.deactivatedForAll.GAMEPAD");

		t.assertTrue("device.MapControls.activatedFor.ALL");
		t.assertTrue("device.MapControls.activatedForAll.MOUSE");
		t.assertTrue("device.MapControls.activatedForAll.KEYBOARD");
		t.assertTrue("device.MapControls.activatedForAll.GAMEPAD");
		t.assertTrue("device.MapControls.deactivatedFor.ALL");
		t.assertTrue("device.MapControls.deactivatedForAll.MOUSE");
		t.assertTrue("device.MapControls.deactivatedForAll.KEYBOARD");
		t.assertTrue("device.MapControls.deactivatedForAll.GAMEPAD");

		t.assertTrue("device.BattleControls.activatedFor.ALL");
		t.assertTrue("device.BattleControls.activatedForAll.MOUSE");
		t.assertTrue("device.BattleControls.activatedForAll.KEYBOARD");
		t.assertTrue("device.BattleControls.activatedForAll.GAMEPAD");
		t.assertTrue("device.BattleControls.deactivatedFor.ALL");
		t.assertTrue("device.BattleControls.deactivatedForAll.MOUSE");
		t.assertTrue("device.BattleControls.deactivatedForAll.KEYBOARD");
		t.assertTrue("device.BattleControls.deactivatedForAll.GAMEPAD");

		#if FLX_STEAMWRAP
		t.assertTrue("device.MenuControls.activatedForAll.STEAM_CONTROLLER");
		t.assertTrue("device.MenuControls.deactivatedForAll.STEAM_CONTROLLER");
		t.assertTrue("device.MapControls.activatedForAll.STEAM_CONTROLLER");
		t.assertTrue("device.MapControls.deactivatedForAll.STEAM_CONTROLLER");
		t.assertTrue("device.BattleControls.activatedForAll.STEAM_CONTROLLER");
		t.assertTrue("device.BattleControls.deactivatedForAll.STEAM_CONTROLLER");
		#end

		t.destroy();
	}

	@Test
	function testDeviceConnectedDisconnected()
	{
		#if flash
		return;
		#end

		var testManager = new FlxActionManager();
		var managerText = '{"actionSets":[{"name":"MenuControls","analogActions":["menu_move"],"digitalActions":["menu_up","menu_down","menu_left","menu_right","menu_select","menu_menu","menu_cancel","menu_thing_1","menu_thing_2","menu_thing_3"]},{"name":"MapControls","analogActions":["scroll_map","move_map"],"digitalActions":["map_select","map_exit","map_menu","map_journal"]},{"name":"BattleControls","analogActions":["move"],"digitalActions":["punch","kick","jump"]}]}';
		var actionsJson = Json.parse(managerText);
		testManager.initFromJson(actionsJson, null, null);

		var menuSet:Int = testManager.getSetIndex("MenuControls");
		testManager.activateSet(menuSet, FlxInputDevice.GAMEPAD, FlxInputDeviceID.ALL);

		connectStr = "";
		disconnectStr = "";

		testManager.deviceConnected.add(deviceConnected);
		testManager.deviceDisconnected.add(deviceRemoved);

		#if FLX_JOYSTICK_API
		FlxG.stage.dispatchEvent(new JoystickEvent(JoystickEvent.DEVICE_ADDED, false, false, 0, 0, 0, 0, 0));
		Assert.isTrue(connectStr == "gamepad_0_xinput");
		FlxG.stage.dispatchEvent(new JoystickEvent(JoystickEvent.DEVICE_ADDED, false, false, 1, 0, 2, 0, 0));
		Assert.isTrue(connectStr == "gamepad_0_xinput,gamepad_1_ps4");
		FlxG.stage.dispatchEvent(new JoystickEvent(JoystickEvent.DEVICE_REMOVED, false, false, 0, 0, 0, 0, 0));
		#elseif (!flash && FLX_GAMEINPUT_API)
		// The model identifiers say "unknown" here because we're not able to spoof all the way down to SDL, from which the gamepads originate

		var xinput = makeFakeGamepad("0", "xinput", FlxGamepadModel.XINPUT);
		Assert.isTrue(connectStr == "gamepad_1_unknown");

		var ps4 = makeFakeGamepad("1", "wireless controller", FlxGamepadModel.PS4);
		Assert.isTrue(connectStr == "gamepad_1_unknown,gamepad_2_unknown");

		removeGamepad(xinput);
		Assert.isTrue(disconnectStr == "gamepad_1_unknown");

		removeGamepad(ps4);
		Assert.isTrue(disconnectStr == "gamepad_1_unknown,gamepad_2_unknown");
		#end

		testManager.deviceConnected.remove(deviceConnected);
		testManager.deviceDisconnected.remove(deviceRemoved);
	}

	function deviceConnected(Device:FlxInputDevice, ID:Int, Model:String)
	{
		if (connectStr != "")
			connectStr += ",";
		connectStr += (Std.string(Device) + "_" + ID + "_" + Model).toLowerCase();
	}

	function deviceRemoved(Device:FlxInputDevice, ID:Int, Model:String)
	{
		if (disconnectStr != "")
			disconnectStr += ",";
		disconnectStr += (Std.string(Device) + "_" + ID + "_" + Model).toLowerCase();
	}

	#if (!flash && FLX_GAMEINPUT_API)
	function removeGamepad(g:Gamepad)
	{
		@:privateAccess GameInput.__onGamepadDisconnect(g);
	}

	function makeFakeGamepad(id:String, name:String, model:FlxGamepadModel):Gamepad
	{
		var limegamepad = @:privateAccess new Gamepad(0);
		@:privateAccess GameInput.__onGamepadConnect(limegamepad);
		var gamepad = FlxG.gamepads.getByID(0);
		gamepad.model = model;
		var gid:GameInputDevice = @:privateAccess gamepad._device;

		@:privateAccess gid.id = id;
		@:privateAccess gid.name = name;

		var control:GameInputControl = null;

		for (i in 0...6)
		{
			control = @:privateAccess new GameInputControl(gid, "AXIS_" + i, -1, 1);
			@:privateAccess gid.__axis.set(i, control);
			@:privateAccess gid.__controls.push(control);
		}

		for (i in 0...15)
		{
			control = @:privateAccess new GameInputControl(gid, "BUTTON_" + i, 0, 1);
			@:privateAccess gid.__button.set(i, control);
			@:privateAccess gid.__controls.push(control);
		}

		gamepad.update();
		return limegamepad;
	}
	#end

	@Test
	function testAddRemoveSet()
	{
		var testManager = new FlxActionManager();
		var managerText = '{"actionSets":[{"name":"MenuControls","analogActions":["menu_move"],"digitalActions":["menu_up","menu_down","menu_left","menu_right","menu_select","menu_menu","menu_cancel","menu_thing_1","menu_thing_2","menu_thing_3"]},{"name":"MapControls","analogActions":["scroll_map","move_map"],"digitalActions":["map_select","map_exit","map_menu","map_journal"]},{"name":"BattleControls","analogActions":["move"],"digitalActions":["punch","kick","jump"]}]}';
		var actionsJson = Json.parse(managerText);

		testManager.initFromJson(actionsJson, null, null);

		var setText = '{"name":"ExtraControls","analogActions":["extra_move"],"digitalActions":["extra_up","extra_down","extra_left","extra_right","extra_select","extra_menu","extra_cancel","extra_thing_1","extra_thing_2","extra_thing_3"]}';
		var json = Json.parse(setText);
		var extraSet:FlxActionSet = @:privateAccess FlxActionSet.fromJson(json, null, null);

		testManager.addSet(extraSet);

		var setIndex = testManager.getSetIndex("ExtraControls");
		var setName = testManager.getSetName(setIndex);
		var setObject = testManager.getSet(setIndex);

		Assert.isTrue(setIndex == 3);
		Assert.isTrue(setName == "ExtraControls");
		Assert.isTrue(setObject == extraSet);

		testManager.removeSet(extraSet);

		setObject = testManager.getSet(setIndex);
		setName = testManager.getSetName(setIndex);
		setIndex = testManager.getSetIndex("ExtraControls");

		Assert.isTrue(setIndex == -1);
		Assert.isTrue(setName == "");
		Assert.isTrue(setObject == null);
	}

	@Test
	function testExportToJson()
	{
		var testManager = new FlxActionManager();
		var managerText = '{"actionSets":[{"name":"MenuControls","analogActions":["menu_move"],"digitalActions":["menu_up","menu_down","menu_left","menu_right","menu_select","menu_menu","menu_cancel","menu_thing_1","menu_thing_2","menu_thing_3"]},{"name":"MapControls","analogActions":["scroll_map","move_map"],"digitalActions":["map_select","map_exit","map_menu","map_journal"]},{"name":"BattleControls","analogActions":["move"],"digitalActions":["punch","kick","jump"]}]}';
		var actionsJson = Json.parse(managerText);

		testManager.initFromJson(actionsJson, null, null);

		var testManager2 = new FlxActionManager();
		var outString = testManager.exportToJson();
		var actionsJson2 = Json.parse(outString);

		testManager2.initFromJson(actionsJson2, null, null);

		Assert.isTrue(testManager.numSets == testManager2.numSets);

		var setNames1:String = "";
		var setNames2:String = "";

		var setDigitals1:String = "";
		var setDigitals2:String = "";

		var setAnalogs1:String = "";
		var setAnalogs2:String = "";

		for (i in 0...testManager.numSets)
		{
			setNames1 += testManager.getSetName(i);
			setNames2 += testManager2.getSetName(i);

			var set1:FlxActionSet = testManager.getSet(i);
			var set2:FlxActionSet = testManager2.getSet(i);

			for (j in 0...set1.digitalActions.length)
			{
				setDigitals1 += set1.digitalActions[j].name;
				setDigitals2 += set2.digitalActions[j].name;
			}

			for (j in 0...set1.analogActions.length)
			{
				setAnalogs1 += set1.analogActions[j].name;
				setAnalogs2 += set2.analogActions[j].name;
			}
		}

		Assert.isTrue(setNames1 == setNames2);
		Assert.isTrue(setDigitals1 == setDigitals2);
		Assert.isTrue(setAnalogs1 == setAnalogs2);
	}

	@Test
	function testInputsChanged()
	{
		// This one's tricky!

		/*
			SteamMock.init();
			SteamMock.initFlx();

			valueTest = "";

			var setName = "MenuControls";
			var setIndex = steamManager.getSetIndex(setName);
			var set:FlxActionSet = steamManager.getSet(setIndex);

			//Set up fake steam handles since we don't have Steam to do it automatically
			for (i in 0...set.digitalActions.length)
			{
				var d:FlxActionDigital = set.digitalActions[i];
				@:privateAccess d.steamHandle = i;
			}

			var a:FlxActionAnalog = set.analogActions[0];
			@:privateAccess a.steamHandle = 99;

			var controller = 0;
			var actionsChanged = "";

			step();
			@:privateAccess steamManager.update();

			var dOrigins:Array<EControllerActionOrigin> =
			[
				LEFTPAD_DPADNORTH,
				LEFTPAD_DPADSOUTH,
				LEFTPAD_DPADWEST,
				LEFTPAD_DPADEAST,
				A,
				START,
				B,
				X,
				Y,
				BACK
			];

			var aOrigins:Array<EControllerActionOrigin> =
			[
				LEFTSTICK_MOVE
			];

			for (i in 0...set.digitalActions.length)
			{
				var d:FlxActionDigital = set.digitalActions[i];
				SteamMock.setDigitalActionOrigins(controller, setIndex, @:privateAccess d.steamHandle, [dOrigins[i]]);
			}
			for (i in 0...set.analogActions.length)
			{
				var a:FlxActionAnalog = set.analogActions[i];
				SteamMock.setAnalogActionOrigins(controller, setIndex, @:privateAccess a.steamHandle, [aOrigins[i]]);
			}

			//Set up a signal callback for when inputs are changed (by our fake simulation of attaching a Steam Controller)
			steamManager.inputsChanged.add(
				function(arr:Array<FlxAction>)
				{
					for (i in 0...arr.length)
					{
						actionsChanged += arr[i].name;
						if (i != arr.length-1)
						{
							actionsChanged += ",";
						}
					}
				}
			);

			//Activate this action set for Steam Controller 1 (handle 0), which should attach steam inputs to the actions under the hood, and trigger our signal
			steamManager.activateSet(setIndex, FlxInputDevice.STEAM_CONTROLLER, controller);

			step();
			@:privateAccess steamManager.update();

			//The Steam API explicitly recommends we activate the set continuously, so we will simulate that here
			steamManager.activateSet(setIndex, FlxInputDevice.STEAM_CONTROLLER, controller);

			step();
			@:privateAccess steamManager.update();

			var finalValue = actionsChanged;

			Assert.isTrue(finalValue == "menu_up,menu_down,menu_left,menu_right,menu_select,menu_menu,menu_cancel,menu_thing_1,menu_thing_2,menu_thing_3,menu_move");
		 */
	}

	@Ignore("Failing on CPP / haxe stable?") @Test
	function testUpdateAndCallbacks()
	{
		var managerText = '{"actionSets":[{"name":"MenuControls","analogActions":["menu_move"],"digitalActions":["menu_up","menu_down","menu_left","menu_right","menu_select","menu_menu","menu_cancel","menu_thing_1","menu_thing_2","menu_thing_3"]},{"name":"MapControls","analogActions":["scroll_map","move_map"],"digitalActions":["map_select","map_exit","map_menu","map_journal"]},{"name":"BattleControls","analogActions":["move"],"digitalActions":["punch","kick","jump"]}]}';
		var actionsJson = Json.parse(managerText);
		var testManager = new FlxActionManager();
		testManager.initFromJson(actionsJson, null, null);

		var keys = [
			FlxKey.A, FlxKey.B, FlxKey.C, FlxKey.D, FlxKey.E, FlxKey.F, FlxKey.G, FlxKey.H, FlxKey.I, FlxKey.J
		];

		var setIndex = testManager.getSetIndex("MenuControls");
		var set = testManager.getSet(setIndex);
		testManager.activateSet(setIndex, FlxInputDevice.ALL, FlxInputDeviceID.ALL);

		for (i in 0...set.digitalActions.length)
		{
			var action:FlxActionDigital = set.digitalActions[i];
			action.add(new FlxActionInputDigitalKeyboard(keys[i], flixel.input.FlxInputState.JUST_PRESSED));
			action.callback = function(a:FlxActionDigital)
			{
				onCallback(a.name);
			};
		}

		set.analogActions[0].add(new FlxActionInputAnalogMouseMotion(MOVED));
		set.analogActions[0].callback = function(a:FlxActionAnalog)
		{
			onCallback(a.name);
		};

		valueTest = "";

		for (key in keys)
		{
			clearFlxKey(key, testManager);
			clickFlxKey(key, true, testManager);
		}

		step();
		@:privateAccess testManager.update();

		moveMousePosition(100, 100, testManager);

		step();
		@:privateAccess testManager.update();

		var finalValue = Std.string(valueTest);

		// cleanup
		for (key in keys)
		{
			clearFlxKey(key, testManager);
		}
		moveMousePosition(0, 0, testManager);

		Assert.isTrue(finalValue == "menu_up,menu_down,menu_left,menu_right,menu_select,menu_menu,menu_cancel,menu_thing_1,menu_thing_2,menu_thing_3,menu_move");
	}

	function createFlxActionManager()
	{
		basicManager = new FlxActionManager();

		var actionsText = '{"actionSets":[{"name":"MenuControls","analogActions":["menu_move"],"digitalActions":["menu_up","menu_down","menu_left","menu_right","menu_select","menu_menu","menu_cancel","menu_thing_1","menu_thing_2","menu_thing_3"]},{"name":"MapControls","analogActions":["scroll_map","move_map"],"digitalActions":["map_select","map_exit","map_menu","map_journal"]},{"name":"BattleControls","analogActions":["move"],"digitalActions":["punch","kick","jump"]}]}';
		var actionsJson = Json.parse(actionsText);

		basicManager.initFromJson(actionsJson, null, null);

		#if FLX_STEAMWRAP
		steamManager = new FlxActionManager();

		var vdfText = VDFString.get();
		var config = ControllerConfig.fromVDF(vdfText);

		steamManager.initSteam(config, null, null);
		#end
	}

	function runFlxActionManagerInit(test:TestShell, ?manager:FlxActionManager)
	{
		if (manager == null)
			manager = basicManager;

		for (i in 0...3)
		{
			var set = sets[i];
			var analogs = analog[i];
			var digitals = digital[i];

			var setIndex:Int = manager.getSetIndex(set);
			var setName:String = manager.getSetName(setIndex);
			var setObject:FlxActionSet = manager.getSet(setIndex);

			test.prefix = set + ".";

			test.testBool(setIndex != -1, "indexExists");
			test.testBool(setName == set, "nameMatches");
			test.testBool(setObject != null, "setExists");
		}
	}

	function runFlxActionManagerActions(test:TestShell, ?manager:FlxActionManager)
	{
		if (manager == null)
			manager = basicManager;

		for (i in 0...3)
		{
			var set = sets[i];
			var analogs = analog[i];
			var digitals = digital[i];

			var setIndex:Int = manager.getSetIndex(set);
			var setName:String = manager.getSetName(setIndex);
			var setObject:FlxActionSet = manager.getSet(setIndex);

			test.prefix = set + ".";

			test.testBool(setObject.digitalActions != null && setObject.digitalActions.length > 0, "hasDigital");
			test.testBool(setObject.analogActions != null && setObject.analogActions.length > 0, "hasAnalog");

			// Test digital actions exist
			for (j in 0...setObject.digitalActions.length)
			{
				var d:FlxActionDigital = setObject.digitalActions[j];
				test.testBool(digitals.indexOf(d.name) != -1, "digital." + d.name + ".exists");
			}

			// Test analog actions exist
			for (j in 0...setObject.analogActions.length)
			{
				var a:FlxActionAnalog = setObject.analogActions[j];
				test.testBool(analogs.indexOf(a.name) != -1, "analog." + a.name + ".exists");
			}
		}
	}

	function runFlxActionManagerAddRemove(test:TestShell, ?manager:FlxActionManager)
	{
		if (manager == null)
			manager = basicManager;

		for (i in 0...3)
		{
			var set = sets[i];
			var analogs = analog[i];
			var digitals = digital[i];

			var setIndex:Int = manager.getSetIndex(set);
			var setName:String = manager.getSetName(setIndex);
			var setObject:FlxActionSet = manager.getSet(setIndex);

			test.prefix = set + ".";

			// Test add & remove digital actions
			var extraDigital = new FlxActionDigital("extra");
			var result = manager.addAction(extraDigital, setIndex);
			test.testBool(result && setObject.digitalActions.indexOf(extraDigital) != -1, "digital.extra.add");
			result = manager.removeAction(extraDigital, setIndex);
			test.testBool(result && setObject.digitalActions.indexOf(extraDigital) == -1, "digital.extra.remove");

			// Test add & remove analog actions
			var extraAnalog = new FlxActionAnalog("extra");
			var result = manager.addAction(extraAnalog, setIndex);
			test.testBool(result && setObject.analogActions.indexOf(extraAnalog) != -1, "analog.extra.add");
			result = manager.removeAction(extraAnalog, setIndex);
			test.testBool(result && setObject.analogActions.indexOf(extraAnalog) == -1, "analog.extra.remove");
		}
	}

	function runFlxActionManagerDevice(device:FlxInputDevice, test:TestShell, ?manager:FlxActionManager)
	{
		if (manager == null)
			manager = basicManager;

		for (i in 0...3)
		{
			var set = sets[i];
			var analogs = analog[i];
			var digitals = digital[i];

			var setIndex:Int = manager.getSetIndex(set);
			var setName:String = manager.getSetName(setIndex);
			var setObject:FlxActionSet = manager.getSet(setIndex);

			test.prefix = set + ".";

			// Test activating action sets for a device
			manager.deactivateSet(setIndex);
			var dset = manager.getSetActivatedForDevice(device);
			manager.activateSet(setIndex, device, FlxInputDeviceID.ALL);
			var activatedSet = manager.getSetActivatedForDevice(device);

			// Test set is activated after we activate it for a specific device
			test.testBool(setObject == activatedSet, "activatedFor." + device);

			var devices:Array<FlxInputDevice> = [MOUSE, KEYBOARD, GAMEPAD, #if FLX_STEAMWRAP STEAM_CONTROLLER, #end ALL];

			for (otherDevice in devices)
			{
				var activatedOtherSet = manager.getSetActivatedForDevice(otherDevice);

				if (device == ALL)
				{
					// Test set is activated for every device
					test.testBool(activatedSet == activatedOtherSet, "activatedForAll." + otherDevice);
				}
				else if (otherDevice != device)
				{
					// Test set is NOT activated for every other device
					test.testBool(activatedSet != activatedOtherSet, "notActivatedFor." + otherDevice + ".but." + device);
				}
			}

			manager.deactivateSet(setIndex);
			activatedSet = manager.getSetActivatedForDevice(device);

			// Test set is deactivated after we deactivate it
			test.testBool(setObject != activatedSet, "deactivatedFor." + device);

			for (otherDevice in devices)
			{
				var activatedOtherSet = manager.getSetActivatedForDevice(otherDevice);

				if (device == ALL)
				{
					// Test set is deactivated for every device
					test.testBool(setObject != activatedOtherSet, "deactivatedForAll." + otherDevice);
				}
				else if (otherDevice != device)
				{
					// Test set is still not activated for every other device
					test.testBool(setObject != activatedOtherSet, "stillNotActivatedFor." + otherDevice + ".but." + device);
				}
			}
		}
	}

	@:access(flixel.input.FlxKeyManager)
	function clickFlxKey(key:FlxKey, pressed:Bool, manager:FlxActionManager)
	{
		if (FlxG.keys == null || FlxG.keys._keyListMap == null)
			return;

		var input:FlxInput<Int> = FlxG.keys._keyListMap.get(key);
		if (input == null)
			return;

		step();
		@:privateAccess manager.update();

		if (pressed)
		{
			input.press();
		}
		else
		{
			input.release();
		}

		@:privateAccess manager.update();
	}

	@:access(flixel.input.FlxKeyManager)
	function clearFlxKey(key:FlxKey, manager:FlxActionManager)
	{
		var input:FlxInput<Int> = FlxG.keys._keyListMap.get(key);
		if (input == null)
			return;
		input.release();
		step();
		@:privateAccess manager.update();
		step();
		@:privateAccess manager.update();
	}

	function moveMousePosition(X:Float, Y:Float, manager:FlxActionManager)
	{
		if (FlxG.mouse == null)
			return;
		step();
		FlxG.mouse.setGlobalScreenPositionUnsafe(X, Y);
		@:privateAccess manager.update();
	}

	function onCallback(str:String)
	{
		if (valueTest != "")
		{
			valueTest += ",";
		}
		valueTest += str;
	}
}
