package states;

import flash.display.Graphics;
import flash.geom.Rectangle;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import nape.callbacks.CbType;
import nape.constraint.DistanceJoint;
import nape.constraint.WeldJoint;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.Material;

/**
 * ...
 * @author TiagoLr (~~~ ProG4mr ~~~)
 * @link https://github.com/ProG4mr
 */
class Blob extends BaseState
{
	static var CIRCLE_RADIUS = 20;
	static var NUM_CIRCLES = 15;
	static var BLOB_RADIUS = 50;
	static var BLOB_COLOR = 0x00824A;
	static var OUTLINE_COLOR = 0x00f58f;
	static var NUM_TWINKLES = 7;
	
	var CB_IGNOREME:CbType = new CbType();
	
	var shooter:Shooter;
	var listBlobCircles:Array<FlxNapeSprite>;
	var blob:FlxSprite; // FlxSprite that displays blob graphics.
	var leftEye:Eye;
	var rightEye:Eye;
	var startYOffset:Float = -250;
	var startXOffset:Float;
	
	override public function create():Void 
	{
		super.create();
		FlxNapeSpace.init();
		
		add(new FlxSprite(0, 0, "assets/BlobBground.jpg"));
		
		startXOffset = FlxG.random.float( -200, 200);	
		
		FlxNapeSpace.createWalls(0,-1000,0,0,10, new Material(1,1, 2,1,0.001));
		FlxNapeSpace.space.gravity.setxy(0, 500);
		
		shooter = new Shooter();
		add(shooter);														 
		
		createBlob();
		
		for (i in 0...NUM_TWINKLES)
		{
			var t:Twinkle = new Twinkle();
			add(t);
			shooter.registerPhysSprite(t);
			
		}
		
		add(new FlxSprite(0, 0, "assets/BlobFground.png"));
		
		var txt:FlxText;
		txt = new FlxText( -10, 5, 640, "      'R' - reset state, 'G' - toggle physics graphics");
		add(txt);
		txt = new FlxText( -10, 20, 640, "      'LEFT' & 'RIGHT' - switch demo");
		add(txt);
	}
	
	function createBlob() 
	{
		listBlobCircles = new Array<FlxNapeSprite>();
		
		var i:Int = 0;
		
		// Creates the circle bodies.
		while (i < 360) 
		{
			var angle = FlxAngle.asRadians(i);
			var circle:FlxNapeSprite = new FlxNapeSprite(FlxG.width / 2 + Math.cos(angle) * BLOB_RADIUS + startXOffset, FlxG.height / 2 + Math.sin(angle) * BLOB_RADIUS + startYOffset);
			circle.createCircularBody(CIRCLE_RADIUS);
			circle.body.allowRotation = false;
			circle.setBodyMaterial(1, 0.1, 2, 1, 0.001);
			circle.makeGraphic(CIRCLE_RADIUS * 2, CIRCLE_RADIUS * 2, 0xFFFFFFFF); // Creates the dummie circle graphic used to add mouse events to this NapeSprite. 
			circle.alpha = 0.01;
			circle.body.isBullet = true;
			listBlobCircles.push(circle);
			add(circle);
			
			shooter.registerPhysSprite(circle);
			
			i += Std.int(360 / NUM_CIRCLES);
		}
		// Connect circle boddies using distance joints to create soft body.
		var b1:Body = null;
		var b2:Body = null;
		for (circle in listBlobCircles)
		{
			b2 = b1;
			b1 = circle.body;
			
			
			var filter = new InteractionFilter(2, ~2);
			b1.setShapeFilters(filter);
			
			if (b2 == null) 
			{
				b2 = listBlobCircles[listBlobCircles.length - 1].body;// first element will link to last one.
			}
			
			var median = new Vec2(b1.position.x + (b2.position.x - b1.position.x) / 2, b1.position.y + (b2.position.y - b1.position.y) / 2);
			var constrain:WeldJoint = new WeldJoint(b1, b2,
													b1.worldPointToLocal(median),
													b2.worldPointToLocal(median),
													0);
			
			//constrain.damping = 1;
			constrain.frequency = 7;
			constrain.stiff = false;
			constrain.space = FlxNapeSpace.space;
			
			
		}
		// Creates the display flxsprite.
		blob = new FlxSprite(0, 0);
		blob.makeGraphic(640, 480, 0x0);
		add(blob);
		// Creates the eyes.
		leftEye = new Eye();
		rightEye = new Eye();
		add(leftEye);
		add(rightEye);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		//###### Draws blob outline
		var gfx:Graphics = FlxSpriteUtil.flashGfxSprite.graphics;
		gfx.clear();
		//gfx.beginFill(BLOB_COLOR, 1);
		gfx.lineStyle(CIRCLE_RADIUS * 2, OUTLINE_COLOR, 1);
		
		var b:Body;
		b = listBlobCircles[listBlobCircles.length - 1].body;
		gfx.moveTo(b.position.x, b.position.y);
		b = listBlobCircles[0].body;
		gfx.lineTo(b.position.x, b.position.y);
		
		for (i in 1...listBlobCircles.length)
		{
			b = listBlobCircles[i].body;
			gfx.lineTo(b.position.x, b.position.y);
		}
		
		gfx.beginFill(BLOB_COLOR, 1);
		gfx.lineStyle(CIRCLE_RADIUS * 2 - 2, BLOB_COLOR, 1);
		
		b = listBlobCircles[listBlobCircles.length - 1].body;
		gfx.moveTo(b.position.x, b.position.y);
		b = listBlobCircles[0].body;
		gfx.lineTo(b.position.x, b.position.y);
		
		for (i in 1...listBlobCircles.length)
		{
			b = listBlobCircles[i].body;
			gfx.lineTo(b.position.x, b.position.y);
		}
		
		gfx.endFill();
		//######
		
		// Copies generated graphics to blob sprite.
		blob.pixels.fillRect(new Rectangle(0, 0, 640, 480), 0x0);
		FlxSpriteUtil.updateSpriteGraphic(blob);
		
		// Positions Eyes in the middle of the blob, using the median x and y values of the blob.
		var medX:Float = 0;
		var medY:Float = 0;
		var body:Body;
		
		for (i in 1...5)
		{
			body = listBlobCircles[Std.int(i * NUM_CIRCLES / 4) - 1].body;
			medX += body.position.x; 
			medY += body.position.y;
		}
		
		medX /= 4;
		medY /= 4;
		
		leftEye.setPos(medX - 28, medY - 10);
		rightEye.setPos(medX + 28, medY - 10);	
	}
}

class Eye extends FlxGroup
{
	var outerEye:FlxSprite;
	var innerEye:FlxSprite;
	
	var eyeRadius:Float = 15;
	var x:Float = 0;
	var y:Float = 0;
	
	public function new()
	{
		super();
		
		outerEye = new FlxSprite(0,0);
		outerEye.makeGraphic(Std.int(eyeRadius * 2), Std.int(eyeRadius * 2), 0x0, true);
		FlxSpriteUtil.drawCircle(outerEye, eyeRadius, eyeRadius, eyeRadius, FlxColor.WHITE);
		outerEye.offset.x = outerEye.width / 2;
		outerEye.offset.y = outerEye.height / 2;
		add(outerEye);
		
		innerEye = new FlxSprite(0,0);
		innerEye.makeGraphic(Std.int(eyeRadius * 2), Std.int(eyeRadius * 2), 0x0, true);
		FlxSpriteUtil.drawCircle(innerEye, eyeRadius, eyeRadius, eyeRadius / 2, FlxColor.BLACK);
		innerEye.offset.x = outerEye.width / 2;
		innerEye.offset.y = outerEye.height / 2;
		add(innerEye);
	}
	
	public function setPos(X:Float, Y:Float)
	{
		x = X;
		y = Y;
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var distance:Vec2 = new Vec2(FlxG.mouse.screenX - x, FlxG.mouse.screenY - y);
		
		outerEye.x = x;
		outerEye.y = y;
		
		//if (distance.length > eyeRadius / 2)
		distance = (distance.unit()).mul(eyeRadius / 2);
		
		innerEye.x = Math.floor(x + distance.x);
		innerEye.y = Math.floor(y + distance.y);
	}
}

class Twinkle extends FlxNapeSprite
{
	var destinationTimer:Float = 0;
	var radius:Float;
	var destinationJoint:DistanceJoint;
	
	function new()
	{
		var rand = FlxG.random.int(0, 4);
		var graphic:String = null;
		
		switch (rand)
		{
			case 0: graphic = "assets/Twinkle10Y.png"; radius = 10;
			case 1: graphic = "assets/Twinkle3Y.png"; radius = 3;
			case 2: graphic = "assets/Twinkle4B.png"; radius = 4;
			case 3: graphic = "assets/Twinkle5B.png"; radius = 5;
			case 4: graphic = "assets/Twinkle5Y.png"; radius = 5;
		}
		
		super(FlxG.random.float(50, 540), FlxG.random.float(200, 480), graphic);
		body.allowRotation = false;
		
		createCircularBody(radius);
		
		setBodyMaterial(1, 0.2, 0.4, 250); 		// set stupid high density to be less afected by blob weight.
		body.gravMass = 0; 						// cancels gravity for this object.
		
		destinationJoint = new DistanceJoint(FlxNapeSpace.space.world, body, new Vec2(body.position.x, body.position.y),
								body.localCOM, 0, 0);
		
		//constrain.active = false; <- default is true
		destinationJoint.stiff = false;  
		//destinationJoint.damping = 0;
		destinationJoint.frequency = .22 + radius * 2 / 100;
		
		destinationJoint.anchor1 = new Vec2(body.position.x, body.position.y);
		destinationJoint.space = FlxNapeSpace.space;		 
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (destinationTimer <= 0)
		{
			destinationTimer = FlxG.random.float(0.6, 4.6);
			
			var newX = body.position.x + FlxG.random.float( -100, 100);
			var newY = body.position.y + FlxG.random.float( -100, 100);
			
			if (newX > 640 - 50) newX = 640 - 50;
			if (newX < 50) newX = 50;
			
			if (newY > 480 - 100) newY = 480 - 100;
			if (newY < 100) newY = 100;
			
			destinationJoint.anchor1 = new Vec2(newX, newY);
		}
		
		destinationTimer -= elapsed;
	}
}