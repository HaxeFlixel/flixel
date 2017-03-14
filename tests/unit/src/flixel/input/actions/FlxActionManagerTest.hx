package flixel.input.actions;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import haxe.Json;

import massive.munit.Assert;

/**
 * ...
 * @author 
 */
class FlxActionManagerTest extends FlxTest
{

	private var manager:FlxActionManager;
	private var sets:Array<String>;
	private var analog:Array<Array<String>>;
	private var digital:Array<Array<String>>;
	
	@Before
	function before()
	{
		manager = _createFlxActionManager();
		sets = 
		[
			"MenuControls", 
			"MapControls", 
			"BattleControls"
		];
		analog = 
		[
			["menu_move"],
			["scroll_map", "move_map"],
			["move"]
		];
		digital = [
			["menu_up", "menu_down", "menu_left", "menu_right", "menu_select", "menu_menu", "menu_cancel", "menu_thing_1", "menu_thing_2", "menu_thing_3"],
			["map_select", "map_exit", "map_menu", "map_journal"],
			["punch", "kick", "jump"]
		];
	}
	
	@After
	function after()
	{
		manager.destroy();
	}
	
	@Test
	function testInit()
	{
		Assert.isTrue(manager.numSets == 3);
		
		var t = new TestShell("init.");
		
		_testFlxActionManagerInit(t);
		
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
	
	@Test
	function testActions()
	{
		var t = new TestShell("actions.");
		
		_testFlxActionManagerActions(t);
		
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
	
	@Test
	function testAddRemove()
	{
		var t = new TestShell("addRemove.");
		
		_testFlxActionManagerAddRemove(t);
		
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
		
		_testFlxActionManagerDevice(MOUSE, t);
		
		t.assertTrue("device.MenuControls.activatedFor.MOUSE");
		t.assertTrue("device.MenuControls.notActivatedFor.KEYBOARD.but.MOUSE");
		t.assertTrue("device.MenuControls.notActivatedFor.GAMEPAD.but.MOUSE");
		t.assertTrue("device.MenuControls.notActivatedFor.STEAM_CONTROLLER.but.MOUSE");
		t.assertTrue("device.MenuControls.deactivatedFor.MOUSE");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.KEYBOARD.but.MOUSE");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.GAMEPAD.but.MOUSE");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.STEAM_CONTROLLER.but.MOUSE");
		
		t.assertTrue("device.MapControls.activatedFor.MOUSE");
		t.assertTrue("device.MapControls.notActivatedFor.KEYBOARD.but.MOUSE");
		t.assertTrue("device.MapControls.notActivatedFor.GAMEPAD.but.MOUSE");
		t.assertTrue("device.MapControls.notActivatedFor.STEAM_CONTROLLER.but.MOUSE");
		t.assertTrue("device.MapControls.deactivatedFor.MOUSE");
		t.assertTrue("device.MapControls.stillNotActivatedFor.KEYBOARD.but.MOUSE");
		t.assertTrue("device.MapControls.stillNotActivatedFor.GAMEPAD.but.MOUSE");
		t.assertTrue("device.MapControls.stillNotActivatedFor.STEAM_CONTROLLER.but.MOUSE");
		
		t.assertTrue("device.BattleControls.activatedFor.MOUSE");
		t.assertTrue("device.BattleControls.notActivatedFor.KEYBOARD.but.MOUSE");
		t.assertTrue("device.BattleControls.notActivatedFor.GAMEPAD.but.MOUSE");
		t.assertTrue("device.BattleControls.notActivatedFor.STEAM_CONTROLLER.but.MOUSE");
		t.assertTrue("device.BattleControls.deactivatedFor.MOUSE");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.KEYBOARD.but.MOUSE");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.GAMEPAD.but.MOUSE");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.STEAM_CONTROLLER.but.MOUSE");
		
		t.destroy();
	}
	
	@Test
	function testKeyboard()
	{
		var t = new TestShell("device.");
		
		_testFlxActionManagerDevice(KEYBOARD, t);
		
		t.assertTrue("device.MenuControls.activatedFor.KEYBOARD");
		t.assertTrue("device.MenuControls.notActivatedFor.MOUSE.but.KEYBOARD");
		t.assertTrue("device.MenuControls.notActivatedFor.GAMEPAD.but.KEYBOARD");
		t.assertTrue("device.MenuControls.notActivatedFor.STEAM_CONTROLLER.but.KEYBOARD");
		t.assertTrue("device.MenuControls.deactivatedFor.KEYBOARD");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.MOUSE.but.KEYBOARD");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.GAMEPAD.but.KEYBOARD");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.STEAM_CONTROLLER.but.KEYBOARD");
		
		t.assertTrue("device.MapControls.activatedFor.KEYBOARD");
		t.assertTrue("device.MapControls.notActivatedFor.MOUSE.but.KEYBOARD");
		t.assertTrue("device.MapControls.notActivatedFor.GAMEPAD.but.KEYBOARD");
		t.assertTrue("device.MapControls.notActivatedFor.STEAM_CONTROLLER.but.KEYBOARD");
		t.assertTrue("device.MapControls.deactivatedFor.KEYBOARD");
		t.assertTrue("device.MapControls.stillNotActivatedFor.MOUSE.but.KEYBOARD");
		t.assertTrue("device.MapControls.stillNotActivatedFor.GAMEPAD.but.KEYBOARD");
		t.assertTrue("device.MapControls.stillNotActivatedFor.STEAM_CONTROLLER.but.KEYBOARD");
		
		t.assertTrue("device.BattleControls.activatedFor.KEYBOARD");
		t.assertTrue("device.BattleControls.notActivatedFor.MOUSE.but.KEYBOARD");
		t.assertTrue("device.BattleControls.notActivatedFor.GAMEPAD.but.KEYBOARD");
		t.assertTrue("device.BattleControls.notActivatedFor.STEAM_CONTROLLER.but.KEYBOARD");
		t.assertTrue("device.BattleControls.deactivatedFor.KEYBOARD");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.MOUSE.but.KEYBOARD");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.GAMEPAD.but.KEYBOARD");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.STEAM_CONTROLLER.but.KEYBOARD");
		
		t.destroy();
	}
	
	@Test
	function testGamepad()
	{
		var t = new TestShell("device.");
		
		_testFlxActionManagerDevice(GAMEPAD, t);
		
		t.assertTrue("device.MenuControls.activatedFor.GAMEPAD");
		t.assertTrue("device.MenuControls.notActivatedFor.MOUSE.but.GAMEPAD");
		t.assertTrue("device.MenuControls.notActivatedFor.KEYBOARD.but.GAMEPAD");
		t.assertTrue("device.MenuControls.notActivatedFor.STEAM_CONTROLLER.but.GAMEPAD");
		t.assertTrue("device.MenuControls.deactivatedFor.GAMEPAD");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.MOUSE.but.GAMEPAD");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.KEYBOARD.but.GAMEPAD");
		t.assertTrue("device.MenuControls.stillNotActivatedFor.STEAM_CONTROLLER.but.GAMEPAD");
		
		t.assertTrue("device.MapControls.activatedFor.GAMEPAD");
		t.assertTrue("device.MapControls.notActivatedFor.MOUSE.but.GAMEPAD");
		t.assertTrue("device.MapControls.notActivatedFor.KEYBOARD.but.GAMEPAD");
		t.assertTrue("device.MapControls.notActivatedFor.STEAM_CONTROLLER.but.GAMEPAD");
		t.assertTrue("device.MapControls.deactivatedFor.GAMEPAD");
		t.assertTrue("device.MapControls.stillNotActivatedFor.MOUSE.but.GAMEPAD");
		t.assertTrue("device.MapControls.stillNotActivatedFor.KEYBOARD.but.GAMEPAD");
		t.assertTrue("device.MapControls.stillNotActivatedFor.STEAM_CONTROLLER.but.GAMEPAD");
		
		t.assertTrue("device.BattleControls.activatedFor.GAMEPAD");
		t.assertTrue("device.BattleControls.notActivatedFor.MOUSE.but.GAMEPAD");
		t.assertTrue("device.BattleControls.notActivatedFor.KEYBOARD.but.GAMEPAD");
		t.assertTrue("device.BattleControls.notActivatedFor.STEAM_CONTROLLER.but.GAMEPAD");
		t.assertTrue("device.BattleControls.deactivatedFor.GAMEPAD");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.MOUSE.but.GAMEPAD");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.KEYBOARD.but.GAMEPAD");
		t.assertTrue("device.BattleControls.stillNotActivatedFor.STEAM_CONTROLLER.but.GAMEPAD");
		
		t.destroy();
	}
	
	@Test
	function testSteamController()
	{
		var t = new TestShell("device.");
		
		_testFlxActionManagerDevice(STEAM_CONTROLLER, t);
		
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
	
	@Test
	function testAllDevices()
	{
		var t = new TestShell("device.");
		
		_testFlxActionManagerDevice(ALL, t);
		
		t.assertTrue("device.MenuControls.activatedFor.ALL");
		t.assertTrue("device.MenuControls.activatedForAll.MOUSE");
		t.assertTrue("device.MenuControls.activatedForAll.KEYBOARD");
		t.assertTrue("device.MenuControls.activatedForAll.GAMEPAD");
		t.assertTrue("device.MenuControls.activatedForAll.STEAM_CONTROLLER");
		t.assertTrue("device.MenuControls.deactivatedFor.ALL");
		t.assertTrue("device.MenuControls.deactivatedForAll.MOUSE");
		t.assertTrue("device.MenuControls.deactivatedForAll.KEYBOARD");
		t.assertTrue("device.MenuControls.deactivatedForAll.GAMEPAD");
		t.assertTrue("device.MenuControls.deactivatedForAll.STEAM_CONTROLLER");
		
		t.assertTrue("device.MapControls.activatedFor.ALL");
		t.assertTrue("device.MapControls.activatedForAll.MOUSE");
		t.assertTrue("device.MapControls.activatedForAll.KEYBOARD");
		t.assertTrue("device.MapControls.activatedForAll.GAMEPAD");
		t.assertTrue("device.MapControls.activatedForAll.STEAM_CONTROLLER");
		t.assertTrue("device.MapControls.deactivatedFor.ALL");
		t.assertTrue("device.MapControls.deactivatedForAll.MOUSE");
		t.assertTrue("device.MapControls.deactivatedForAll.KEYBOARD");
		t.assertTrue("device.MapControls.deactivatedForAll.GAMEPAD");
		t.assertTrue("device.MapControls.deactivatedForAll.STEAM_CONTROLLER");
		
		t.assertTrue("device.BattleControls.activatedFor.ALL");
		t.assertTrue("device.BattleControls.activatedForAll.MOUSE");
		t.assertTrue("device.BattleControls.activatedForAll.KEYBOARD");
		t.assertTrue("device.BattleControls.activatedForAll.GAMEPAD");
		t.assertTrue("device.BattleControls.activatedForAll.STEAM_CONTROLLER");
		t.assertTrue("device.BattleControls.deactivatedFor.ALL");
		t.assertTrue("device.BattleControls.deactivatedForAll.MOUSE");
		t.assertTrue("device.BattleControls.deactivatedForAll.KEYBOARD");
		t.assertTrue("device.BattleControls.deactivatedForAll.GAMEPAD");
		t.assertTrue("device.BattleControls.deactivatedForAll.STEAM_CONTROLLER");
		
		t.destroy();
	}
	
	private function _createFlxActionManager():FlxActionManager
	{
		var manager = new FlxActionManager();
		
		var actionsText = '{"actionSets":[{"name":"MenuControls","analogActions":["menu_move"],"digitalActions":["menu_up","menu_down","menu_left","menu_right","menu_select","menu_menu","menu_cancel","menu_thing_1","menu_thing_2","menu_thing_3"]},{"name":"MapControls","analogActions":["scroll_map","move_map"],"digitalActions":["map_select","map_exit","map_menu","map_journal"]},{"name":"BattleControls","analogActions":["move"],"digitalActions":["punch","kick","jump"]}]}';
		var actionsJSON = Json.parse(actionsText);
		
		manager.initFromJSON(actionsJSON, null, null);
		
		return manager;
	}
	
	function _testFlxActionManagerInit(test:TestShell)
	{
		for (i in 0...3)
		{
			var set = sets[i];
			var analogs = analog[i];
			var digitals = digital[i];
			
			var setIndex:Int = manager.getSetIndex(set);
			var setName:String = manager.getSetName(setIndex);
			var setObject:FlxActionSet = manager.getSet(setIndex);
			
			test.prefix = set + ".";
			
			test.testIsTrue(setIndex != -1, "indexExists");
			test.testIsTrue(setName == set, "nameMatches");
			test.testIsTrue(setObject != null, "setExists");
		}
	}
	
	function _testFlxActionManagerActions(test:TestShell)
	{
		for (i in 0...3)
		{
			var set = sets[i];
			var analogs = analog[i];
			var digitals = digital[i];
			
			var setIndex:Int = manager.getSetIndex(set);
			var setName:String = manager.getSetName(setIndex);
			var setObject:FlxActionSet = manager.getSet(setIndex);
			
			test.prefix = set + ".";
			
			test.testIsTrue(setObject.digitalActions != null && setObject.digitalActions.length > 0, "hasDigital");
			test.testIsTrue(setObject.analogActions != null && setObject.analogActions.length > 0, "hasAnalog");
			
			//Test digital actions exist
			for (j in 0...setObject.digitalActions.length)
			{
				var d:FlxActionDigital = setObject.digitalActions[j];
				test.testIsTrue(digitals.indexOf(d.name) != -1, "digital."+d.name+".exists");
			}
			
			//Test analog actions exist
			for (j in 0...setObject.analogActions.length)
			{
				var a:FlxActionAnalog = setObject.analogActions[j];
				test.testIsTrue(analogs.indexOf(a.name) != -1, "analog." + a.name+".exists");
			}
		}
	}
	
	function _testFlxActionManagerAddRemove(test:TestShell)
	{
		for (i in 0...3)
		{
			var set = sets[i];
			var analogs = analog[i];
			var digitals = digital[i];
			
			var setIndex:Int = manager.getSetIndex(set);
			var setName:String = manager.getSetName(setIndex);
			var setObject:FlxActionSet = manager.getSet(setIndex);
			
			test.prefix = set + ".";
			
			//Test add & remove digital actions
			var extraDigital = new FlxActionDigital("extra");
			var result = manager.addDigitalAction(extraDigital, setIndex);
			test.testIsTrue(result && setObject.digitalActions.indexOf(extraDigital) != -1, "digital.extra.add");
			result = manager.removeDigitalAction(extraDigital, setIndex);
			test.testIsTrue(result && setObject.digitalActions.indexOf(extraDigital) == -1, "digital.extra.remove");
			
			//Test add & remove analog actions
			var extraAnalog = new FlxActionAnalog("extra");
			var result = manager.addAnalogAction(extraAnalog, setIndex);
			test.testIsTrue(result && setObject.analogActions.indexOf(extraAnalog) != -1, "analog.extra.add");
			result = manager.removeAnalogAction(extraAnalog, setIndex);
			test.testIsTrue(result && setObject.analogActions.indexOf(extraAnalog) == -1, "analog.extra.remove");
		}
	}
	
	function _testFlxActionManagerDevice(device:FlxInputDevice, test:TestShell)
	{
		for (i in 0...3)
		{
			var set = sets[i];
			var analogs = analog[i];
			var digitals = digital[i];
			
			var setIndex:Int = manager.getSetIndex(set);
			var setName:String = manager.getSetName(setIndex);
			var setObject:FlxActionSet = manager.getSet(setIndex);
			
			test.prefix = set + ".";
			
			//Test activating action sets for a device
			manager.deactivateSet(setIndex);
			var dset = manager.getSetActivatedForDevice(device);
			manager.activateSet(setIndex, device);
			var activatedSet = manager.getSetActivatedForDevice(device);
			
			//Test set is activated after we activate it for a specific device
			test.testIsTrue(setObject == activatedSet, "activatedFor." + device);
			
			var devices:Array<FlxInputDevice> = 
			[
				MOUSE,
				KEYBOARD,
				GAMEPAD,
				STEAM_CONTROLLER,
				ALL
			];
			
			for (otherDevice in devices)
			{
				var activatedOtherSet = manager.getSetActivatedForDevice(otherDevice);
				
				if (device == ALL)
				{
					//Test set is activated for every device
					test.testIsTrue(activatedSet == activatedOtherSet, "activatedForAll." + otherDevice);
				}
				else if (otherDevice != device)
				{
					//Test set is NOT activated for every other device
					test.testIsTrue(activatedSet != activatedOtherSet, "notActivatedFor." + otherDevice+ ".but." + device);
				}
			}
			
			manager.deactivateSet(setIndex);
			activatedSet = manager.getSetActivatedForDevice(device);
			
			//Test set is deactivated after we deactivate it
			test.testIsTrue(setObject != activatedSet, "deactivatedFor." + device);
			
			for (otherDevice in devices)
			{
				var activatedOtherSet = manager.getSetActivatedForDevice(otherDevice);
				
				if (device == ALL)
				{
					//Test set is deactivated for every device
					test.testIsTrue(setObject != activatedOtherSet, "deactivatedForAll." + otherDevice);
				}
				else if (otherDevice != device)
				{
					//Test set is still not activated for every other device
					test.testIsTrue(setObject != activatedOtherSet, "stillNotActivatedFor." + otherDevice+".but."+device);
				}
			}
		}
	}
	
	@Test
	function testDeviceDisconnected()
	{
		
	}
	
	@Test
	function testDeviceConnected()
	{
		
	}
	
	@Test
	function testInputsChanged()
	{
		
	}
	
	@Test
	function testAddSet()
	{
		
	}
	
	@Test
	function testInitSteam()
	{
		
	}
	
	@Test
	function testExportToJSON()
	{
		
	}
	
	@Test
	function testRemoveSet()
	{
		
	}
}

