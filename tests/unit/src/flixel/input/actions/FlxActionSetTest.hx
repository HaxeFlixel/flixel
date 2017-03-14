package flixel.input.actions;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;
import flixel.input.actions.FlxActionInput.FlxInputType;
import haxe.Json;

import massive.munit.Assert;

/**
 * ...
 * @author 
 */
class FlxActionSetTest extends FlxTest
{

	@Before
	function before()
	{
		
	}
	
	@Test
	function testFromJSON()
	{
		var text = '{"name":"MenuControls","analogActions":["menu_move"],"digitalActions":["menu_up","menu_down","menu_left","menu_right","menu_select","menu_menu","menu_cancel","menu_thing_1","menu_thing_2","menu_thing_3"]}';
		var json = Json.parse(text);
		var set:FlxActionSet = @:privateAccess FlxActionSet.fromJSON(json, null, null);
		
		Assert.isTrue(set.name == "MenuControls");
		Assert.isTrue(set.analogActions != null);
		Assert.isTrue(set.analogActions.length == 1);
		Assert.isTrue(set.digitalActions != null);
		Assert.isTrue(set.digitalActions.length == 10);
		
		var analog = ["menu_move"];
		var digital = ["menu_up", "menu_down", "menu_left", "menu_right", "menu_select", "menu_menu", "menu_cancel", "menu_thing_1", "menu_thing_2", "menu_thing_3"];
		
		var hasAnalog = false;
		
		for (a in analog){
			hasAnalog = false;
			for (aa in set.analogActions)
			{
				if (aa.name == a)
				{
					hasAnalog = true;
				}
			}
			if (!hasAnalog)
			{
				break;
			}
		}
		
		Assert.isTrue(hasAnalog);
		
		var hasDigital = false;
		
		for (d in digital){
			hasDigital = false;
			for (dd in set.digitalActions)
			{
				if (dd.name == d)
				{
					hasDigital = true;
				}
			}
			if (!hasDigital)
			{
				break;
			}
		}
		
		Assert.isTrue(hasDigital);
	}
	
	@Test
	function testToJSON()
	{
		var text = '{"name":"MenuControls","analogActions":["menu_move"],"digitalActions":["menu_up","menu_down","menu_left","menu_right","menu_select","menu_menu","menu_cancel","menu_thing_1","menu_thing_2","menu_thing_3"]}';
		var json = Json.parse(text);
		var set:FlxActionSet = @:privateAccess FlxActionSet.fromJSON(json, null, null);
		
		var outJson = set.toJSON();
		
		var out:{name:String, analogActions:Array<String>, digitalActions:Array<String>} = Json.parse(outJson);
		
		var name = "MenuControls";
		var analogActions = ["menu_move"];
		var digitalActions = ["menu_up", "menu_down", "menu_left", "menu_right", "menu_select", "menu_menu", "menu_cancel", "menu_thing_1", "menu_thing_2", "menu_thing_3"];
		
		Assert.isTrue(out.name == name);
		
		var analogEquivalent = out.analogActions.length == analogActions.length;
		var digitalEquivalent = out.digitalActions.length == digitalActions.length;
		
		if (analogEquivalent)
		{
			for (i in 0...analogActions.length)
			{
				if (out.analogActions.indexOf(analogActions[i]) == -1)
				{
					analogEquivalent == false;
					break;
				}
			}
		}
		
		Assert.isTrue(analogEquivalent);
		
		if (digitalEquivalent)
		{
			for (i in 0...digitalActions.length)
			{
				if (out.digitalActions.indexOf(digitalActions[i]) == -1)
				{
					digitalEquivalent == false;
					break;
				}
			}
		}
		
		Assert.isTrue(digitalEquivalent);
	}
	
	@Test
	function testAddRemoveDigital()
	{
		var set = new FlxActionSet("test", [], []);
		
		Assert.isTrue(set.digitalActions.length == 0);
		
		var d1 = new FlxActionDigital("d1");
		var d2 = new FlxActionDigital("d2");
		
		set.addDigital(d1);
		Assert.isTrue(set.digitalActions.length == 1);
		set.addDigital(d2);
		Assert.isTrue(set.digitalActions.length == 2);
		
		set.removeDigital(d1);
		Assert.isTrue(set.digitalActions.length == 1);
		Assert.isTrue(set.digitalActions[0] == d2);
		set.removeDigital(d2);
		Assert.isTrue(set.digitalActions.length == 0);
	}
	
	@Test
	function testAddRemoveAnalog()
	{
		var set = new FlxActionSet("test", [], []);
		
		Assert.isTrue(set.analogActions.length == 0);
		
		var a1 = new FlxActionAnalog("a1");
		var a2 = new FlxActionAnalog("a2");
		
		set.addAnalog(a1);
		Assert.isTrue(set.analogActions.length == 1);
		set.addAnalog(a2);
		Assert.isTrue(set.analogActions.length == 2);
		
		set.removeAnalog(a1);
		Assert.isTrue(set.analogActions.length == 1);
		Assert.isTrue(set.analogActions[0] == a2);
		set.removeAnalog(a2);
		Assert.isTrue(set.analogActions.length == 0);
	}
	
	@Test
	function testCallbacks()
	{
		//
	}
	
	@Test
	function testAttachSteamController()
	{
		//
	}

}