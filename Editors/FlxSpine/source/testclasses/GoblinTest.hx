package testclasses;
import flixel.FlxG;
import spinehx.Animation;
import spinehx.Skeleton;
import spinehx.SkeletonData;
import flixel.addons.editors.spine.FlxSpine;

/**
 * ...
 * @author Kris
 */
class GoblinTest extends FlxSpine
{
	public function new(skeletonData:SkeletonData,  X:Float = 0, Y:Float = 0) 
	{
		super(skeletonData, X, Y);
		
		var animation = skeletonData.findAnimation("walk");
		
		skeleton.setSkinByName("goblin");
		skeleton.setToSetupPose();
		skeleton = Skeleton.copy(skeleton);
		skeleton.setX(250);
        skeleton.setY(320);
        skeleton.setFlipY(true);
		skeleton.updateWorldTransform();
	}
	
	override public function update(elapsed:Float):Void
	{
		
/*		var x:Float = skeleton.getX() + 160 * deltaTime * (skeleton.getFlipX() ? -1 : 1);
		if (x > FlxG.stage.stageWidth) skeleton.setFlipX(true);
		if (x < 0) skeleton.setFlipX(false);
        skeleton.setX(x);*/

		
		if (FlxG.mouse.justPressed)
		{
	
			skeleton.setSkinByName(skeleton.getSkin().getName() == "goblin" ? "goblingirl" : "goblin");
			skeleton.setSlotsToSetupPose();
			 
		}
		
		super.update(elapsed);
	}
	
}