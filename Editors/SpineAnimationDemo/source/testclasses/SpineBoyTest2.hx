package  testclasses;
import spinehx.Animation;
import spinehx.Bone;
import spinehx.SkeletonData;
import flixel.addons.editors.spine.FlxSpine;

/**
 * ...
 * @author Kris
 */
class SpineBoyTest2 extends FlxSpine
{

	
	private var walkAnimation:Animation;
	private var jumpAnimation:Animation;
	
	public function new( skeletonData:SkeletonData,  X:Float = 0, Y:Float = 0, Width:Int = 0, Height:Int = 0 ) 
	{
		super( skeletonData, X, Y, Width, Height );
		
		walkAnimation = skeletonData.findAnimation("walk");
		jumpAnimation = skeletonData.findAnimation("jump");
		 
		skeleton.setX(200);
        skeleton.setY(320);
		
		timeScale = 0.333;
		
	}
	
	private var time:Float = 0;
	override private function handleAnimations():Void
	{
		var jump:Float = jumpAnimation.getDuration();
		var beforeJump:Float = 1.0;
		var blendIn:Float = 0.4;
		var blendOut:Float = 0.4;
		var blendOutStart:Float = beforeJump + jump - blendOut;
		var total:Float = 3.75;

		time += delta;

		var root_:Bone = skeleton.getRootBone();
		var speed:Float = 180;
		if (time > beforeJump + blendIn && time < blendOutStart) speed = 360;
		//root_.setX(root_.getX() + speed * delta);

		// This shows how to manage state manually. See AnimationStatesTest.
		if (time > total) {
			// restart
			time = 0;
			//root_.setX(-50);
		} else if (time > beforeJump + jump) {
			// just walk after jump
			walkAnimation.apply(skeleton, time, true);
		} else if (time > blendOutStart) {
			// blend out jump
			walkAnimation.apply(skeleton, time, true);
			jumpAnimation.mix(skeleton, time - beforeJump, false, 1 - (time - blendOutStart) / blendOut);
		} else if (time > beforeJump + blendIn) {
			// just jump
			jumpAnimation.apply(skeleton, time - beforeJump, false);
		} else if (time > beforeJump) {
			// blend in jump
			walkAnimation.apply(skeleton, time, true);
			jumpAnimation.mix(skeleton, time - beforeJump, false, (time - beforeJump) / blendIn);
		} else {
			// just walk before jump
			walkAnimation.apply(skeleton, time, true);
		}
	}
	
}