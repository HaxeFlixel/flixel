package;

import flixel.FlxG;
import flixel.math.FlxVector;

/**
 * The template for all levels, driven by txt file data.
 * @author MSGHero
 */
class Template
{
	public var mirrors(default, null):Array<Segment>;
	public var targets(default, null):Array<Circle>;
	public var colors(default, null):Array<Color>;
	
	var mirrorsDefault:Array<Segment>;
	var targetsDefault:Array<Circle>;
	var colorsDefault:Array<Color>;
	
	public function new(data:String)
	{
		targetsDefault = [];
		mirrorsDefault = [];
		colorsDefault = [];
		
		addPolyMirror([FlxVector.get(50, 0), FlxVector.get(FlxG.width, 0), FlxVector.get(FlxG.width, FlxG.height), FlxVector.get(50, FlxG.height)], false); // border walls
		
		parseData(data);
		reset();
	}
	
	public function reset():Void
	{
		// these arrays get manipulated during the game, so we need to retain a "master" array and copy from that
		targets = targetsDefault.copy();
		mirrors = mirrorsDefault.copy();
		colors = colorsDefault.copy();
	}
	
	public function parseData(data:String):Void
	{
		var regex = new EReg("(\r\n)|\r|\n", "g"); // split data by \n, \r, or \r\n
		var rows = regex.split(data);
		
		var targetRow = rows[0];
		var targetsData = targetRow.split("; ");
		
		// parse the targets: targetCenterX targetCenterY targetRadius targetColor; ... (color is one of RBYOGPW)
		for (targetData in targetsData)
		{
			var params = targetData.split(" ");
			targetsDefault.push(new Circle(FlxVector.get(Std.parseFloat(params[0]), Std.parseFloat(params[1])), Std.parseFloat(params[2]), getColorFromData(params[3])));
		}
		
		// parse the mirrors: mirrorPt1X mirrorPt1Y mirrorPt2X mirrorPt2Y; ... (the first and last points will connect if there are 3 or more. border will already be defined)
		var mirrorRow = rows[1];
		var mirrorsData = mirrorRow.split("; ");
		
		for (mirrorData in mirrorsData)
		{
			var params = mirrorData.split(" ");
			var verts = [];
			var numVerts = Std.int(params.length / 2);
			
			for (i in 0...numVerts)
			{
				verts.push(FlxVector.get(Std.parseFloat(params[2 * i]), Std.parseFloat(params[2 * i + 1])));
			}
			
			if (numVerts == 2)
			{
				mirrorsDefault.push(Segment.fromEndpoints(verts[0], verts[1], Color.MIRROR));
			}
			
			else
			{
				addPolyMirror(verts, true);
			}
		}
		
		// color1color2color3 ... (each color is one of RBYOGPW)
		var colorData = rows[2];
		
		for (i in 0...colorData.length)
		{
			colorsDefault.push(getColorFromData(colorData.charAt(i)));
		}
	}
	
	function getColorFromData(char:String):Color
	{
		return switch (char)
		{
			case "R": Color.RED;
			case "O": Color.ORANGE;
			case "Y": Color.YELLOW;
			case "G": Color.GREEN;
			case "B": Color.BLUE;
			case "P": Color.PURPLE;
			default: Color.WHITE;
		}
	}
	
	function addPolyMirror(verts:Array<FlxVector>, visible:Bool = true):Void
	{
		// connects all the vertices with mirror segments, including the first and last ones
		var start = verts[verts.length - 1], vert:FlxVector, segment:Segment;
		for (i in 0...verts.length)
		{
			vert = verts[i];
			
			segment = Segment.fromEndpoints(start, vert, Color.MIRROR);
			start = vert;
			
			mirrorsDefault.push(segment);
		}
	}
}