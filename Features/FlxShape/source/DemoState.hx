package;

import flixel.addons.display.shapes.FlxShapeArrow;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.addons.display.shapes.FlxShapeCross;
import flixel.addons.display.shapes.FlxShapeDonut;
import flixel.addons.display.shapes.FlxShapeDoubleCircle;
import flixel.addons.display.shapes.FlxShapeGrid;
import flixel.addons.display.shapes.FlxShapeLightning;
import flixel.addons.display.shapes.FlxShapeLine;
import flixel.addons.display.shapes.FlxShapeSquareDonut;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import openfl.display.CapsStyle;
import openfl.display.JointStyle;

/**
 * ...
 * @author larsiusprime
 */
class DemoState extends FlxState
{
	var box:FlxShapeBox;
	var circle:FlxShapeCircle;
	var cross:FlxShapeCross;
	var cross2:FlxShapeCross;
	var donut:FlxShapeDonut;
	var sdonut:FlxShapeSquareDonut;
	
	var dcircle:FlxShapeDoubleCircle;
	var grid:FlxShapeGrid;
	
	var line:FlxShapeLine;
	var lightning:FlxShapeLightning;
	
	var norg_back:FlxShapeBox;
	var norg_cross:FlxShapeCross;
	var norg_cross2:FlxShapeCross;
	
	public override function create():Void
	{
		super.create();
		
		box = new FlxShapeBox(10, 10, 50, 50, { thickness:8, color:FlxColor.WHITE }, FlxColor.BLUE);
		add(box);
		
		circle = new FlxShapeCircle(10, 70, 25, { thickness:8, color:FlxColor.YELLOW }, FlxColor.BLUE);
		add(circle);
		
		donut = new FlxShapeDonut(10, 130, 25, 10, { thickness:8, color:FlxColor.MAGENTA }, FlxColor.WHITE);
		add(donut);
		
		cross = new FlxShapeCross(10, 190, 50, 25, 50, 25, 0.5, 0.5, { thickness:8, color:FlxColor.RED, capsStyle:CapsStyle.SQUARE, jointStyle:JointStyle.MITER}, FlxColor.PINK);
		add(cross);
		
		cross2 = new FlxShapeCross(70, 190, 37.5, 12.5, 50, 12.5, 0.5, 0.25, { thickness:4, color:FlxColor.GRAY, capsStyle:CapsStyle.SQUARE, jointStyle:JointStyle.MITER}, FlxColor.WHITE);
		add(cross2);
		
		//Norwegian Flag! -- useful test for boundaries lining up
		
		norg_back = new FlxShapeBox(130, 190, 50, 37.5, { thickness:0, color:FlxColor.TRANSPARENT }, FlxColor.RED);
		norg_cross = new FlxShapeCross(130, 190, 50, 16, 37.5, 16, 0.33, 0.5, { thickness:0, color:FlxColor.TRANSPARENT }, FlxColor.WHITE);
		norg_cross2 = new FlxShapeCross(130, 190, 50, 8, 37.5, 8, 0.36, 0.5, { thickness:0, color:FlxColor.TRANSPARENT }, FlxColor.BLUE);
		add(norg_back);
		add(norg_cross);
		add(norg_cross2);
		
		dcircle = new FlxShapeDoubleCircle(10, 250, 25, 10, { thickness:8, color:FlxColor.MAGENTA }, FlxColor.WHITE);
		add(dcircle);
		
		grid = new FlxShapeGrid(10, 310, 10, 10, 10, 10, { thickness:2, color:FlxColor.WHITE }, FlxColor.BLUE);
		add(grid);
		
		line = new FlxShapeLine(10, 420, new FlxPoint(0, 0), new FlxPoint(25, 25), { thickness:8, color:FlxColor.LIME} );
		add(line);
		
		lightning = new FlxShapeLightning(130, 10, new FlxPoint(0, 0), new FlxPoint(50, 50),{thickness:4, color:FlxColor.WHITE, displacement:100});
		add(lightning);
		
		sdonut = new FlxShapeSquareDonut(130, 90, 25, 12.5, { thickness:4, color:FlxColor.WHITE}, FlxColor.MAGENTA);
		add(sdonut);
		
		var arrow_nw = new FlxShapeArrow(190   , 130   , new FlxPoint(50, 50), new FlxPoint( 0,  0), 10.0, { thickness:4, color:FlxColor.WHITE }, { thickness:6, color:FlxColor.BLUE } );
		var arrow_n  = new FlxShapeArrow(190+50, 130   , new FlxPoint( 0, 50), new FlxPoint( 0,  0), 10.0, { thickness:4, color:FlxColor.WHITE }, { thickness:6, color:FlxColor.BLUE } );
		var arrow_ne = new FlxShapeArrow(190+50, 130   , new FlxPoint( 0, 50), new FlxPoint(50,  0), 10.0, { thickness:4, color:FlxColor.WHITE }, { thickness:6, color:FlxColor.BLUE } );
		var arrow_e  = new FlxShapeArrow(190   , 130+50, new FlxPoint(50,  0), new FlxPoint( 0,  0), 10.0, { thickness:4, color:FlxColor.WHITE }, { thickness:6, color:FlxColor.BLUE } );
		var arrow_se = new FlxShapeArrow(190+50, 130+50, new FlxPoint( 0,  0), new FlxPoint(50, 50), 10.0, { thickness:4, color:FlxColor.WHITE }, { thickness:6, color:FlxColor.BLUE } );
		var arrow_s  = new FlxShapeArrow(190+50, 130+50, new FlxPoint( 0,  0), new FlxPoint( 0, 50), 10.0, { thickness:4, color:FlxColor.WHITE }, { thickness:6, color:FlxColor.BLUE } );
		var arrow_sw = new FlxShapeArrow(190   , 130+50, new FlxPoint(50,  0), new FlxPoint( 0, 50), 10.0, { thickness:4, color:FlxColor.WHITE }, { thickness:6, color:FlxColor.BLUE } );
		var arrow_w =  new FlxShapeArrow(190+50, 130+50, new FlxPoint( 0,  0), new FlxPoint(50,  0), 10.0, { thickness:4, color:FlxColor.WHITE }, { thickness:6, color:FlxColor.BLUE } );
	
		add(arrow_nw);
		add(arrow_n);
		add(arrow_ne);
		add(arrow_e);
		add(arrow_sw);
		add(arrow_s);
		add(arrow_se);
		add(arrow_w);
	}
}