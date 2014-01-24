<<<<<<< HEAD
/*
import flixel.addons.ui.shapes.FlxShapeArrow;
import flixel.addons.ui.shapes.FlxShapeBox;
import flixel.addons.ui.shapes.FlxShapeCircle;
import flixel.addons.ui.shapes.FlxShapeCross;
import flixel.addons.ui.shapes.FlxShapeDonut;
import flixel.addons.ui.shapes.FlxShapeDoubleCircle;
import flixel.addons.ui.shapes.FlxShapeGrid;
import flixel.addons.ui.shapes.FlxShapeLightning;
import flixel.addons.ui.shapes.FlxShapeLine;
import flixel.addons.ui.shapes.FlxShapeSquareDonut;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil.FillStyle;
import flixel.util.FlxSpriteUtil.LineStyle;
import haxe.xml.Fast;
import flash.Lib;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
*/
/**
 * @author Lars Doucet
 */

 /*
=======
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
import flixel.addons.ui.FlxUIState;
import flixel.FlxG;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil.FillStyle;
import flixel.util.FlxSpriteUtil.LineStyle;

/**
 * @author Lars Doucet
 */
>>>>>>> 0c36408119f44c98e161b4338a7cb5b93f906a51
class State_TestShapes extends FlxUIState
{
	override public function create() 
	{
		_xml_id = "state_shapes";
		super.create();
		
		testGrid();
		/*testDoubleCircles();
		testSquareDonuts();
		testArrow();
		testCross();
		testLightning();
		testDonuts();
		testBoxes();
		testCircles();
		testLines();*/
	}
	
	private function testGrid():Void {
		var lineStyle:LineStyle = { thickness:2, color:0xff0000ff };
		var fillStyle:FillStyle = { color:0xffffffff, hasFill:true, alpha:0.5};
		
		var grid:FlxShapeGrid = new FlxShapeGrid(10, 10, 10, 10, 10, 10, lineStyle, fillStyle);
		add(grid);
	}
	
	private function testArrow():Void {
		var lineStyle:LineStyle = { thickness:10, color:0xffffffff };
		var outlineStyle:LineStyle = { thickness:14, color:0xff000000 };
		var testLine:FlxShapeArrow = new FlxShapeArrow(10, 10, new FlxPoint(0, 0), new FlxPoint(100, 100), 10, lineStyle, outlineStyle);
		var testLine2:FlxShapeArrow = new FlxShapeArrow(200, 10, new FlxPoint(0, 100), new FlxPoint(100, 0), 10, lineStyle, outlineStyle);
		
		var lineStyle2:LineStyle = { thickness:1, color:0xffffffff };
		var outlineStyle2:LineStyle = { thickness:4, color:0xff000000 };
		var testLine3:FlxShapeArrow = new FlxShapeArrow(10, 210, new FlxPoint(0, 0), new FlxPoint(100, 100), 10, lineStyle2, outlineStyle2);
		var testLine4:FlxShapeArrow = new FlxShapeArrow(200, 210, new FlxPoint(0, 100), new FlxPoint(100, 0), 10, lineStyle2, outlineStyle2);
		
		add(testLine);
		add(testLine2);
		add(testLine3);
		add(testLine4);
	}
	
	private function testCross():Void {
		var lineStyle:LineStyle = { thickness:1, color:0xff0000ff };
		var lineStyle2:LineStyle = { thickness:10, color:0xff0000ff };
		var fillStyle:FillStyle = { hasFill:true, color:0xffffffff };
		
		var cross:FlxShapeCross = new FlxShapeCross(10, 10, 100, 50, 100, 50, 0.5, 0.5, lineStyle, fillStyle);
		
		var cross2:FlxShapeCross = new FlxShapeCross(210, 10, 100, 50, 100, 50, 0.5, 0.5, lineStyle2, fillStyle);
		
		var cross3:FlxShapeCross = new FlxShapeCross( 10, 210, 100, 25, 100, 25, 0.5, 0, lineStyle, fillStyle);
		var cross4:FlxShapeCross = new FlxShapeCross(210, 210, 100, 25, 100, 25, 0, 0.5, lineStyle, fillStyle);
		
		add(cross);
		add(cross2);
		add(cross3);
		add(cross4);
	}
	
	private function testLightning():Void {
		var style:LightningStyle = {
			thickness:1,
			color:0xffffffff,
			displacement:100,
			detail:2,
			halo_colors:null,
		}
		
		var style2:LightningStyle = {
			thickness:3,
			color:0xffffffff,
			displacement:100,
			detail:2,
			halo_colors:[0xffffff00,0xffff8800,0xffff0000]
		}
		
		
		var bolt:FlxShapeLightning = new FlxShapeLightning(10, 10, new FlxPoint(0, 0), new FlxPoint(100, 100), style);
		var bolt2:FlxShapeLightning = new FlxShapeLightning(160, 10, new FlxPoint(0, 0), new FlxPoint(100, 100), style);
		var bolt3:FlxShapeLightning = new FlxShapeLightning(310, 10, new FlxPoint(0, 0), new FlxPoint(100, 100), style);
		
		var bolt4:FlxShapeLightning = new FlxShapeLightning(10, 160, new FlxPoint(0, 0), new FlxPoint(100, 100), style2);
		var bolt5:FlxShapeLightning = new FlxShapeLightning(160, 160, new FlxPoint(0, 0), new FlxPoint(100, 100), style2);
		var bolt6:FlxShapeLightning = new FlxShapeLightning(310, 160, new FlxPoint(0, 0), new FlxPoint(100, 100), style2);
		
		var bolt7:FlxShapeLightning = new FlxShapeLightning(10, 310, new FlxPoint(0, 100), new FlxPoint(100, 0), style);
		var bolt8:FlxShapeLightning = new FlxShapeLightning(160, 310, new FlxPoint(0, 100), new FlxPoint(100, 0), style);
		var bolt9:FlxShapeLightning = new FlxShapeLightning(310, 310, new FlxPoint(0, 100), new FlxPoint(100, 0), style);
		
		var bolt10:FlxShapeLightning = new FlxShapeLightning(10, 460, new FlxPoint(100, 0), new FlxPoint(0, 100), style2);
		var bolt11:FlxShapeLightning = new FlxShapeLightning(160, 460, new FlxPoint(100, 0), new FlxPoint(0, 100), style2);
		var bolt12:FlxShapeLightning = new FlxShapeLightning(310, 460, new FlxPoint(100, 0), new FlxPoint(0, 100), style2);
		
		add(bolt);
		add(bolt2);
		add(bolt3);
		
		add(bolt4);
		add(bolt5);
		add(bolt6);
		
		add(bolt7);
		add(bolt8);
		add(bolt9);
		
		add(bolt10);
		add(bolt11);
		add(bolt12);
	}
		
	private function testSquareDonuts():Void {
		var lineStyle:LineStyle = { thickness:10, color:0xff0000ff };
		var lineStyle2:LineStyle = { thickness:1, color:0xff0000ff };
		var fillStyle:FillStyle = { hasFill:true, color:0xffffffff };
		
		var donut:FlxShapeSquareDonut = new FlxShapeSquareDonut(10, 10, 50, 25, lineStyle, fillStyle);
		var donut2:FlxShapeSquareDonut = new FlxShapeSquareDonut(200, 10, 50, 25, lineStyle2, fillStyle);
		
		var donut3:FlxShapeSquareDonut = new FlxShapeSquareDonut(10, 210, 90, 25, lineStyle, fillStyle);
		var donut4:FlxShapeSquareDonut = new FlxShapeSquareDonut(200, 210, 90, 25, lineStyle2, fillStyle);
		
		add(donut);
		add(donut2);
		add(donut3);
		add(donut4);
	}

	private function testDonuts():Void {
		var lineStyle:LineStyle = { thickness:10, color:0xff0000ff };
		var lineStyle2:LineStyle = { thickness:1, color:0xff0000ff };
		var fillStyle:FillStyle = { hasFill:true, color:0xffffffff };
		
		var donut:FlxShapeDonut = new FlxShapeDonut(10, 10, 50, 25, lineStyle, fillStyle);
		var donut2:FlxShapeDonut = new FlxShapeDonut(200, 10, 50, 25, lineStyle2, fillStyle);
		
		var donut3:FlxShapeDonut = new FlxShapeDonut(10, 210, 90, 25, lineStyle, fillStyle);
		var donut4:FlxShapeDonut = new FlxShapeDonut(200, 210, 90, 25, lineStyle2, fillStyle);
		
		add(donut);
		add(donut2);
		add(donut3);
		add(donut4);
	}
	
	private function testDoubleCircles():Void {
		var lineStyle:LineStyle = { thickness:10, color:0xff0000ff };
		var lineStyle2:LineStyle = { thickness:1, color:0xff0000ff };
		var fillStyle:FillStyle = { hasFill:true, color:0xffffffff };
		
		var donut:FlxShapeDoubleCircle = new FlxShapeDoubleCircle(10, 10, 50, 25, lineStyle, fillStyle);
		var donut2:FlxShapeDoubleCircle = new FlxShapeDoubleCircle(200, 10, 50, 25, lineStyle2, fillStyle);
		
		var donut3:FlxShapeDoubleCircle = new FlxShapeDoubleCircle(10, 210, 90, 25, lineStyle, fillStyle);
		var donut4:FlxShapeDoubleCircle = new FlxShapeDoubleCircle(200, 210, 90, 25, lineStyle2, fillStyle);
		
		add(donut);
		add(donut2);
		add(donut3);
		add(donut4);
	}
	
	private function testBoxes():Void {
		var lineStyle:LineStyle = { thickness:10, color:0xff0000ff };
		var lineStyle2:LineStyle = { thickness:1, color:0xff0000ff };
		var fillStyle:FillStyle = { hasFill:true, color:0xffffffff };
		
		var box:FlxShapeBox = new FlxShapeBox(10, 10, 50, 50, lineStyle, fillStyle);
		var box2:FlxShapeBox = new FlxShapeBox(200, 10, 50, 50, lineStyle2, fillStyle);
		
		var box3:FlxShapeBox = new FlxShapeBox(10, 210, 50, 25, lineStyle, fillStyle);
		var box4:FlxShapeBox = new FlxShapeBox(200, 210, 50, 25, lineStyle2, fillStyle);
		
		add(box);
		add(box2);
		add(box3);
		add(box4);
	}
	
	private function testCircles():Void {
		var lineStyle:LineStyle = { thickness:10, color:0xffff0000 };
		var lineStyle2:LineStyle = { thickness:2, color:0xffff0000 };
		var fillStyle:FillStyle = { hasFill:true, color:0xffffffff };
		
		var circle:FlxShapeCircle = new FlxShapeCircle(10, 10, 50, lineStyle, fillStyle);
		var circle2:FlxShapeCircle = new FlxShapeCircle(200, 10, 50, lineStyle2, fillStyle);
		
		add(circle);
		add(circle2);
	}
	
	private function testLines():Void {
		var lineStyle:LineStyle = { thickness:10, color:0xffffffff };
		var testLine:FlxShapeLine = new FlxShapeLine(10, 10, new FlxPoint(0, 0), new FlxPoint(100, 100), lineStyle);
		var testLine2:FlxShapeLine = new FlxShapeLine(200, 10, new FlxPoint(0, 100), new FlxPoint(100, 0), lineStyle);
		
		var lineStyle2:LineStyle = { thickness:1, color:0xffffffff };
		var testLine3:FlxShapeLine = new FlxShapeLine(10, 210, new FlxPoint(0, 0), new FlxPoint(100, 100), lineStyle2);
		var testLine4:FlxShapeLine = new FlxShapeLine(200, 210, new FlxPoint(0, 100), new FlxPoint(100, 0), lineStyle2);
		
		add(testLine);
		add(testLine2);
		add(testLine3);
		add(testLine4);
	}
	
	public override function getRequest(id:String, target:Dynamic, data:Dynamic):Dynamic {
		return null;
	}	
	
	public override function eventResponse(id:String,target:Dynamic,data:Array<Dynamic>):Void {
		if (data != null) {
			switch(cast(data[0], String)) {
				case "back": FlxG.switchState(new State_Title());
			}
		}
	}
	
	public override function update():Void {
		super.update();
	}
	
}*/
