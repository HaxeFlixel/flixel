package;

import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * A group of FlxTexts containing the instructions and current parameter values of the noise.
 */
class HUD extends FlxGroup
{	
	var titleText:FlxText;
	var xText:FlxText;
	var yText:FlxText;
	var scaleText:FlxText;
	var persistenceText:FlxText;
	var octavesText:FlxText;
	var tileText:FlxText;
	var seedText:FlxText;
	var supportText:FlxText;
	
	public function new()
	{
	    super();
	    
	    titleText = new FlxText(420, 10, 210, "FlxSimplex", 24);
	    titleText.alignment = FlxTextAlign.CENTER;
	    
	    // each field represents a parameter of the noise
	    xText = new FlxText(420, 110, 0, null, 14);
	    yText = new FlxText(420, 140, 0, null, 14);
	    scaleText = new FlxText(420, 170, 0, null, 14);
	    persistenceText = new FlxText(420, 200, 0, null, 14);
	    octavesText = new FlxText(420, 230, 0, null, 14);
	    tileText = new FlxText(420, 260, 0, null, 14);
	    seedText = new FlxText(420, 290, 0, null, 14);
	    supportText = new FlxText(10, 420, 610, "WASD and arrow keys to scroll. O/L to change scale (zoom). I/K to change persistence (resolution). U/J to change octaves (detail, more octaves take more time to process). Y to toggle tiled noise. H to randomize the tile seed.", 12);
	    
	    add(titleText);
	    add(xText);
	    add(yText);
	    add(scaleText);
	    add(persistenceText);
	    add(octavesText);
	    add(tileText);
	    add(seedText);
	    add(supportText);
	}
	
	public function updateX(x:Int):Void
	{
		xText.text = 'X: $x';
	}
	
	public function updateY(y:Int):Void
	{
		yText.text = 'Y: $y';
	}
	
	public function updateScale(scale:Float):Void
	{
		scaleText.text = 'Scale: $scale';
	}
	
	public function updatePersistence(persistence:Float):Void
	{
		persistenceText.text = 'Persistence: $persistence';
	}
	
	public function updateOctaves(octaves:Int):Void
	{
		octavesText.text = 'Octaves: $octaves';
	}
	
	public function updateTiles(tiles:Bool):Void
	{
		tileText.text = "Tiling: " + (tiles ? "ON" : "OFF");
	}
	
	public function updateSeed(seed:Int):Void
	{
		seedText.text = 'Seed: $seed';
	}
}