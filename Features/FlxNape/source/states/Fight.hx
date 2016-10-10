package states;

import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import nape.callbacks.CbType;
import nape.callbacks.InteractionType;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.constraint.PivotJoint;
import nape.geom.Vec2;

/**
 * @author TiagoLr (~~~ ProG4mr ~~~)
 * @link https://github.com/ProG4mr
 */
class Fight extends BaseState
{
	var shooter:Shooter;
	
	override public function create():Void 
	{
		FlxNapeSpace.init();
		
		FlxNapeSpace.createWalls(0,-300,FlxG.width, FlxG.height - 30);
		FlxNapeSpace.space.gravity.setxy(0, 400);
		
		add(new FlxSprite(0, 0, "assets/fight/dbzbg.jpg"));
		
		shooter = new Shooter();
		add(shooter);
		
		var songoku = new Ragdoll(100,250);
		songoku.init();
		songoku.createGraphics("Goku");
		add(songoku);
		
		var vegeta = new Ragdoll(550, 250);
		vegeta.init();
		vegeta.createGraphics("Vege");
		add(vegeta);
		
		for (spr in songoku.sprites)
		{
			spr.antialiasing = true;
			shooter.registerPhysSprite(spr);
		}
		for (spr in vegeta.sprites)
		{
			spr.antialiasing = true;
			shooter.registerPhysSprite(spr);
		}
		
		songoku.rLArm.body.applyImpulse(new Vec2(2000, FlxG.random.float( -2700, -2800)));
		vegeta.lLArm.body.applyImpulse(new Vec2( -2000, FlxG.random.float( -2700, -2800)));
		
		var txt:FlxText;
		txt = new FlxText( -10, 5, 640, "      'R' - reset state, 'G' - toggle physics graphics");
		add(txt);
		txt = new FlxText( -10, 20, 640, "      'LEFT' & 'RIGHT' - switch demo");
		add(txt);
	}
}

class Ragdoll extends FlxGroup 
{
	public var sprites:Array<FlxNapeSprite>;
	
	public var rULeg:FlxNapeSprite; // right upper leg.
	public var rLLeg:FlxNapeSprite; // right lower leg.
	public var lULeg:FlxNapeSprite; // left upper leg.
	public var lLLeg:FlxNapeSprite; // left lower leg.
	
	public var rUArm:FlxNapeSprite; // right upper arm.
	public var rLArm:FlxNapeSprite; // right lower arm.
	public var lUArm:FlxNapeSprite; // left upper arm.
	public var lLArm:FlxNapeSprite; // left lower arm.
	
	public var head:FlxNapeSprite; // head.
	
	public var lTorso:FlxNapeSprite; // lower torso.
	public var uTorso:FlxNapeSprite; // upper torso.
	
	public var scale:Float;
	
	public var joints:Array<PivotJoint>;
	
	public var larmSize:FlxPoint;
	public var uarmSize:FlxPoint;
	public var llegSize:FlxPoint;
	public var ulegSize:FlxPoint;
	public var uTorsoSize:FlxPoint;
	public var lTorsoSize:FlxPoint; 
	public var neckHeight:Float;
	public var headRadius:Float;
	
	public var limbOffset:Float;
	public var torsoOffset:Float;
	
	var startX:Float;
	var startY:Float;
	
	/**
	 * Creates the ragdoll
	 * @param	scale	The ragdol size scale factor.
	 */
	public function new(X:Float, Y:Float, Scale:Float = 1)
	{
		super();
		
		Scale > 0 ? scale = Scale : scale = 1;
		
		larmSize = FlxPoint.get(12 * scale, 45 * scale);
		uarmSize = FlxPoint.get(12 * scale, 40 * scale);
		llegSize = FlxPoint.get(15 * scale, 45 * scale);
		ulegSize = FlxPoint.get(15 * scale, 50 * scale);
		uTorsoSize = FlxPoint.get(35 * scale, 35 * scale);
		lTorsoSize = FlxPoint.get(35 * scale, 15 * scale);
		neckHeight = 5 * scale;
		headRadius = 15 * scale;
		
		limbOffset = 3 * scale;
		torsoOffset = 5 * scale;
		
		startX = X;
		startY = Y;
	}
	
	public function init()
	{
		sprites = new Array<FlxNapeSprite>();
		
		uTorso = new FlxNapeSprite(startX, startY); sprites.push(uTorso); 
		lTorso = new FlxNapeSprite(startX, startY + 30); sprites.push(lTorso);
		
		rULeg = new FlxNapeSprite(startX + 20, startY + 100); sprites.push(rULeg);
		rLLeg = new FlxNapeSprite(startX + 20, startY + 150); sprites.push(rLLeg);
		lULeg = new FlxNapeSprite(startX - 20, startY + 100); sprites.push(lULeg);
		lLLeg = new FlxNapeSprite(startX - 20, startY + 150); sprites.push(lLLeg);
		
		rUArm = new FlxNapeSprite(startX + 20, startY); sprites.push(rUArm);
		rLArm = new FlxNapeSprite(startX + 20, startY); sprites.push(rLArm);
		lUArm = new FlxNapeSprite(startX - 20, startY); sprites.push(lUArm);
		lLArm = new FlxNapeSprite(startX - 20, startY); sprites.push(lLArm);
		
		head = new FlxNapeSprite(startX, startY - 40); sprites.push(head);
		
		add(rLLeg);
		add(lLLeg);
		add(rULeg);
		add(lULeg);
		add(rLArm);
		add(lLArm);
		add(rUArm);
		add(lUArm);
		add(lTorso);
		add(uTorso);
		add(head);
		
		createBodies();
		createContactListeners();
		createJoints();
	}
	
	function setPos(x:Float, y:Float)
	{
		for (s in sprites)
		{
			s.body.position.x = x;
			s.body.position.y = y;
		}
	}
	
	function createBodies() 
	{
		rULeg.createRectangularBody(ulegSize.x, ulegSize.y);
		rLLeg.createRectangularBody(llegSize.x, llegSize.y);
		
		lULeg.createRectangularBody(ulegSize.x, ulegSize.y);
		lLLeg.createRectangularBody(llegSize.x, llegSize.y);
		
		lUArm.createRectangularBody(uarmSize.x, uarmSize.y);
		lLArm.createRectangularBody(larmSize.x, larmSize.y);
		
		rUArm.createRectangularBody(uarmSize.x, uarmSize.y);
		rLArm.createRectangularBody(larmSize.x, larmSize.y);
		
		uTorso.createRectangularBody(uTorsoSize.x, uTorsoSize.y);
		lTorso.createRectangularBody(lTorsoSize.x, lTorsoSize.y);
		
		head.createCircularBody(headRadius);
	}
	
	function createContactListeners()
	{
		// group 1 - lower left leg ignores upper left leg 
		// group 2 - lower right leg ignores upper right leg
		// group 3 - upper left legs ignores lower torso 
		// group 4 - upper rigth legs ignores lower torso 
		// group 5 - lower torso
		// group 6 - upper torso ignores upper arms 
		// group 7 - upper arms ignores lower arms | upper torso | lower torso
		// group 8 - lower arms
		
		var group1:CbType = new CbType();
		var group2:CbType = new CbType();
		var group3:CbType = new CbType();
		var group4:CbType = new CbType();
		var group5:CbType = new CbType();
		var group6:CbType = new CbType();
		var group7:CbType = new CbType();
		var group8:CbType = new CbType();
		var group9:CbType = new CbType();
		
		lLLeg.body.cbTypes.add(group1);
		rLLeg.body.cbTypes.add(group2);
		lULeg.body.cbTypes.add(group3);
		rULeg.body.cbTypes.add(group4);
		lTorso.body.cbTypes.add(group5);
		uTorso.body.cbTypes.add(group6);
		lUArm.body.cbTypes.add(group7);
		rUArm.body.cbTypes.add(group7);
		lLArm.body.cbTypes.add(group8);
		rLArm.body.cbTypes.add(group8);
		head.body.cbTypes.add(group9);
		
		
		var listener;
		// lower left leg ignores upper left leg 
		listener = new PreListener(InteractionType.COLLISION, group1, group3, ignoreCollision, 0, true);
		listener.space = FlxNapeSpace.space;
		// lower right leg ignores upper right leg
		listener = new PreListener(InteractionType.COLLISION, group2, group4, ignoreCollision, 0, true);
		listener.space = FlxNapeSpace.space;
		// upper left legs ignores lower torso 
		listener = new PreListener(InteractionType.COLLISION, group3, group5, ignoreCollision, 0, true);
		listener.space = FlxNapeSpace.space;
		// upper rigth legs ignores lower torso 
		listener = new PreListener(InteractionType.COLLISION, group4, group5, ignoreCollision, 0, true);
		listener.space = FlxNapeSpace.space;
		// upper torso ignores upper arms 
		listener = new PreListener(InteractionType.COLLISION, group6, group7, ignoreCollision, 0, true);
		listener.space = FlxNapeSpace.space;
		// upper arms ignores lower arms | upper torso | lower torso
		listener = new PreListener(InteractionType.COLLISION, group7, group8, ignoreCollision, 0, true);
		listener.space = FlxNapeSpace.space;
		listener = new PreListener(InteractionType.COLLISION, group7, group6, ignoreCollision, 0, true);
		listener.space = FlxNapeSpace.space;
		listener = new PreListener(InteractionType.COLLISION, group7, group5, ignoreCollision, 0, true);
		listener.space = FlxNapeSpace.space;

	}
	
	function ignoreCollision(cb:PreCallback):PreFlag
	{
		return PreFlag.IGNORE;
	}
	
	public function createGraphics(prefix:String)
	{
		var getPath = function(part)
		{
			return 'assets/fight/$prefix$part.png';
		}
		
		head.loadGraphic(getPath("Head"));
		uTorso.loadGraphic(getPath("UTorso"));
		lTorso.loadGraphic(getPath("LTorso"));
		
		rULeg.loadGraphic(getPath("ULeg"));
		lULeg.loadGraphic(getPath("ULeg")); lULeg.flipX = true;
		rLLeg.loadGraphic(getPath("LLeg"));
		lLLeg.loadGraphic(getPath("LLeg")); lLLeg.flipX = true;
		
		rUArm.loadGraphic(getPath("UArm"));
		lUArm.loadGraphic(getPath("UArm")); lUArm.flipX = true;
		rLArm.loadGraphic(getPath("LArm"));
		lLArm.loadGraphic(getPath("LArm")); lLArm.flipX = true;
	}
	
	function createJoints() 
	{
		var constrain:PivotJoint;

		// lower legs with upper legs.
		constrain = new PivotJoint(lLLeg.body, lULeg.body, new Vec2(0, -llegSize.y / 2 + 3), new Vec2(0, ulegSize.y / 2 - 3));
		constrain.space = FlxNapeSpace.space;
		constrain = new PivotJoint(rLLeg.body, rULeg.body, new Vec2(0, -llegSize.y / 2 + 3), new Vec2(0, ulegSize.y / 2 - 3));
		constrain.space = FlxNapeSpace.space;
		
		// Lower Arms with upper arms.
		constrain = new PivotJoint(lLArm.body, lUArm.body, new Vec2(0, -larmSize.y / 2 + 3), new Vec2(0, uarmSize.y / 2 - 3));
		constrain.space = FlxNapeSpace.space;
		constrain = new PivotJoint(rLArm.body, rUArm.body, new Vec2(0, -larmSize.y / 2 + 3), new Vec2(0, uarmSize.y / 2 - 3));
		constrain.space = FlxNapeSpace.space;
		
		// Upper legs with lower torso.
		constrain = new PivotJoint(lULeg.body, lTorso.body, new Vec2(0, -ulegSize.y / 2 + 3), new Vec2( -lTorsoSize.x / 2  + ulegSize.x / 2, lTorsoSize.y / 2 - 6));
		constrain.space = FlxNapeSpace.space;
		constrain = new PivotJoint(rULeg.body, lTorso.body, new Vec2(0, -ulegSize.y / 2 + 3), new Vec2(lTorsoSize.x / 2  - ulegSize.x / 2, lTorsoSize.y / 2 - 6));
		constrain.space = FlxNapeSpace.space;
		
		// Upper torso with mid lower.
		constrain = new PivotJoint(uTorso.body, lTorso.body, new Vec2(0, uTorsoSize.y / 2 + torsoOffset), new Vec2(0, -lTorsoSize.y / 2 - torsoOffset));
		constrain.space = FlxNapeSpace.space;
		
		// Upper arms with Upper torso.
		constrain = new PivotJoint(lUArm.body, uTorso.body, new Vec2(uarmSize.x / 2 - 3, -uarmSize.y / 2 + 3), new Vec2( -uTorsoSize.x / 2 + 3, -uTorsoSize.y / 2 + 3));
		constrain.space = FlxNapeSpace.space;
		constrain = new PivotJoint(rUArm.body, uTorso.body, new Vec2( -uarmSize.x / 2 + 3, -uarmSize.y / 2 + 3), new Vec2(uTorsoSize.x / 2 - 3, -uTorsoSize.y / 2 + 3));
		constrain.space = FlxNapeSpace.space;
		
		// Neck with upper torso.
		constrain = new PivotJoint(uTorso.body, head.body, new Vec2(0, -uTorsoSize.y / 2 - neckHeight), new Vec2(0, headRadius));
		constrain.space = FlxNapeSpace.space;
	}
}