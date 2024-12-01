
package flixel.group;

import flixel.FlxBasic;
import flixel.group.FlxContainer;
import massive.munit.Assert;

class FlxContainerTest extends FlxGroupTest
{
	override function makeGroup():FlxGroup
	{
		var group = new FlxContainer();
		for (i in 0...10)
		{
			group.add(new FlxBasic());
		}
		return group;
	}
	
	@Test
	function testMemberCameras()
	{
		final subGroup1 = new FlxContainer();
		group.add(subGroup1);
		final subGroup2 = new FlxTypedContainer<FlxSprite>();
		subGroup1.add(subGroup2);
		final member1 = new FlxSprite();
		final member2 = new FlxSprite();
		subGroup1.add(member1);
		subGroup2.add(member2);
		
		final cam = new FlxCamera();
		group.camera = cam;
		Assert.areEqual(cam, member1.getCameras()[0]);
		Assert.areEqual(cam, member2.getCameras()[0]);
		
		final cams = [new FlxCamera()];
		group.cameras = cams;
		Assert.areEqual(cams, member1.getCameras());
		Assert.areEqual(cams, member2.getCameras());
	}
}
