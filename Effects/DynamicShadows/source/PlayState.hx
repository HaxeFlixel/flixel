package;

import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import nape.geom.Vec2;
import nape.geom.Vec2List;
import nape.phys.Body;
import openfl.display.BlendMode;
import openfl.display.FPS;
using flixel.util.FlxSpriteUtil;

/**
 * This was based on a guide from this forum post: http://forums.tigsource.com/index.php?topic=8803.0
 * Ported to HaxeFlixel by Xerosugar
 * 
 * If you're feeling up the challenge, here's how YOU help can improve this demo:
 * - Make it possible to extends the shadows to the edge of the screen
 * - Make it possible to use multiple light sources while still maintaining a decent frame rate
 * - Improve the performance of *this* demo
 * - Make it possible to blur the edges of the shadows
 * - Make it possible to limit the light source's influence, or "strength"
 * - Your own ideas? :)
 * 
 * @author Tommy Elfving
 */
class PlayState extends FlxState
{
	public static inline var TILE_SIZE:Int = 16;
	
	private static inline var SHADOW_COLOR = 0xff2a2963;
	private static inline var OVERLAY_COLOR = 0xff887fff;
	
	/**
	 * Only contains non-collidabe tiles
	 */
	private var background:FlxTilemap;
	
	/**
	 * The layer into which the actual "level" will be drawn, and also the one objects will collide with
	 */
	private var foreground:FlxNapeTilemap;
	
	/**
	 * The sprite that shadows will be drawn to
	 */
	private var shadowCanvas:FlxSprite;
	
	/**
	 * The sprite that the actual darkness and the gem's flare-like effect will be drawn to
	 */
	private var shadowOverlay:FlxSprite;
	
	/**
	 * The light source!
	 */
	private var gem:Gem;
	
	/**
	 * If there's a small gap between something (could be two tiles,
	 * even if they're right next to each other), this should cover it up for us
	 */
	private var lineStyle:LineStyle = { color: SHADOW_COLOR, thickness: 1 };
	
	private var infoText:FlxText;
	private var fps:FPS;
	
	override public function create():Void
	{
		super.create();
		
		FlxG.camera.bgColor = 0x5a81ad;
		
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity.setxy(0, 1200);
		FlxNapeSpace.drawDebug = false; // You can toggle this on/off one by pressing 'D'
		
		var background:FlxTilemap = new FlxTilemap();
		background.loadMapFromCSV("assets/data/background.txt",
			"assets/images/tiles.png", TILE_SIZE, TILE_SIZE, null, 1, 1);
		add(background);
		
		// Note: The tilemap used in this demo was drawn with 'Tiled' (http://www.mapeditor.org/),
		// but the level data was picked from the .tmx file and put into two separate
		// .txt files for simplicity. If you wish to learn how to use Tiled with your project,
		// have a look at this demo: http://haxeflixel.com/demos/TiledEditor/
		
		// If we add the shadows *before* all of the foreground elements (stage included)
		// they will only cover the background, which is usually what you'd want I'd guess :)
		shadowCanvas = new FlxSprite();
		shadowCanvas.blend = BlendMode.MULTIPLY;
		shadowCanvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		add(shadowCanvas);
		
		foreground = new FlxNapeTilemap();
		foreground.loadMapFromCSV("assets/data/foreground.txt",
			"assets/images/tiles.png", TILE_SIZE, TILE_SIZE, null, 1, 1);
		add(foreground);
		
		foreground.setupTileIndices([4]);
		createProps();
		
		shadowOverlay = new FlxSprite();
		shadowOverlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		shadowOverlay.blend = BlendMode.MULTIPLY;
		add(shadowOverlay);
		
		infoText = new FlxText(10, 10, 100, "");
		add(infoText);
		
		// This here is only used to get the current FPS in a simple way, without having to run the application in Debug mode
		fps = new FPS(10, 10, 0xffffff);
		FlxG.stage.addChild(fps);
		fps.visible = false;
	}
	
	private function createProps():Void
	{
		for (tileY in 0...foreground.heightInTiles)
		{
			for (tileX in 0...foreground.widthInTiles)
			{
				var tileIndex = foreground.getTile(tileX, tileY);
				var xPos:Float = tileX * TILE_SIZE;
				var yPos:Float = tileY * TILE_SIZE;
				
				if (tileIndex == Prop.BARREL)
				{					
					add(new Barrel(xPos, yPos));
					cleanTile(tileX, tileY);
				}
				else if (tileIndex == Prop.GEM)
				{
					gem = new Gem(xPos, yPos);
					add(gem);
					cleanTile(tileX, tileY);
				}
			}
		}
	}
	
	/**
	 * The tile in question was replaced by an actual object, this function will clean up the tile for us
	 */
	private function cleanTile(x:Int, y:Int):Void
	{
		foreground.setTile(x, y, 0);
	}
	
	override public function update(elapsed:Float):Void
	{
		infoText.text = "FPS: " + fps.currentFPS + "\n\nObjects can be dragged/thrown around.\n\nPress 'R' to restart.";
		
		if (FlxG.keys.justPressed.R)
			FlxG.resetState();
		
		if (FlxG.keys.justPressed.D)
			FlxNapeSpace.drawDebug = !FlxNapeSpace.drawDebug;
		
		processShadows();
		super.update(elapsed);
	}
	
	public function processShadows():Void
	{
		shadowCanvas.fill(FlxColor.TRANSPARENT);
		shadowOverlay.fill(OVERLAY_COLOR);

		shadowOverlay.drawCircle( // outer red circle
			gem.body.position.x + FlxG.random.float( -.6, .6),
			gem.body.position.y + FlxG.random.float( -.6, .6),
			(FlxG.random.bool(5) ? 16 : 16.5), 0xffff5f5f);

		shadowOverlay.drawCircle( // inner red circle
			gem.body.position.x + FlxG.random.float( -.25, .25),
			gem.body.position.y + FlxG.random.float( -.25, .25),
			(FlxG.random.bool(5) ? 13 : 13.5), 0xffff7070);

		for (body in FlxNapeSpace.space.bodies)
		{
			// We don't want to draw any shadows around the gem, since it's the light source
			if (body.userData.type != "Gem")
				processBodyShapes(body);
		}
	}
	
	private function processBodyShapes(body:Body)
	{
		for (shape in body.shapes) 
		{
			var verts:Vec2List = shape.castPolygon.worldVerts;
			
			for (i in 0...verts.length) 
			{
				var startVertex:Vec2 = (i == 0) ? verts.at(verts.length - 1) : verts.at(i - 1);
				processShapeVertex(startVertex, verts.at(i));
			}
		}
	}
	
	private function processShapeVertex(startVertex:Vec2, endVertex:Vec2):Void
	{
		var tempLightOrigin:Vec2 = Vec2.get(
			gem.body.position.x + FlxG.random.float( -.3, 3),
			gem.body.position.y + FlxG.random.float(-.3, .3));
		
		if (doesEdgeCastShadow(startVertex, endVertex, tempLightOrigin))
		{
			var projectedPoint:Vec2 = projectPoint(startVertex, tempLightOrigin);
			var prevProjectedPt:Vec2 = projectPoint(endVertex, tempLightOrigin);
			var vts:Array<FlxPoint> = [
				FlxPoint.weak(startVertex.x, startVertex.y),
				FlxPoint.weak(projectedPoint.x, projectedPoint.y),
				FlxPoint.weak(prevProjectedPt.x, prevProjectedPt.y),
				FlxPoint.weak(endVertex.x, endVertex.y)
			];
			
			shadowCanvas.drawPolygon(vts, SHADOW_COLOR, lineStyle);
		}
	}
	
	private function projectPoint(point:Vec2, light:Vec2):Vec2
	{
		var lightToPoint:Vec2 = point.copy();
		lightToPoint.subeq(light);
		
		var projectedPoint:Vec2 = point.copy();
		return projectedPoint.addeq(lightToPoint.muleq(.45));
	}
	
	private function doesEdgeCastShadow(start:Vec2, end:Vec2, light:Vec2):Bool
	{
		var startToEnd:Vec2 = end.copy();
		startToEnd.subeq(start);
		
		var normal:Vec2 = new Vec2(startToEnd.y, -1 * startToEnd.x);
		
		var lightToStart:Vec2 = start.copy();
		lightToStart.subeq(light);
	 
		return normal.dot(lightToStart) > 0;
	}
}

@:enum
abstract Prop(Int) to Int
{
	var BARREL = 5;
	var GEM = 6;
}