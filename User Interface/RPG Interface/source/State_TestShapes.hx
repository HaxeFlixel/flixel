import flixel.addons.ui.shapes.FlxShapeBox;
import flixel.addons.ui.shapes.FlxShapeCircle;
import flixel.addons.ui.shapes.FlxShapeDonut;
import flixel.addons.ui.shapes.FlxShapeLightning;
import flixel.addons.ui.shapes.FlxShapeLine;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil.FillStyle;
import flixel.util.FlxSpriteUtil.LineStyle;
import haxe.xml.Fast;
import flash.Lib;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
/**
 * @author Lars Doucet
 */

class State_TestShapes extends FlxUIState
{

	override public function create() 
	{
		_xml_id = "state_shapes";
		super.create();
		
		testLightning();
		//testDonuts();
		//testBoxes();
		//testCircles();
		//testLines();
	}
	
	private function testLightning():Void {
		var style:LightningStyle = {
			thickness:1,
			color:0xffffffff,
			displacement:75,
			detail:1,
			halo_colors:null,
		}
		
		var style2:LightningStyle = {
			thickness:3,
			color:0xffffffff,
			displacement:75,
			detail:1,
			halo_colors:[0xffffff00,0xffff8800,0xffff0000]
		}
		
		
		var bolt:FlxShapeLightning = new FlxShapeLightning(10, 10, new FlxPoint(0, 0), new FlxPoint(100, 100), style);
		var bolt2:FlxShapeLightning = new FlxShapeLightning(120, 10, new FlxPoint(0, 0), new FlxPoint(100, 100), style);
		var bolt3:FlxShapeLightning = new FlxShapeLightning(230, 10, new FlxPoint(0, 0), new FlxPoint(100, 100), style);
		
		var bolt4:FlxShapeLightning = new FlxShapeLightning(10, 120, new FlxPoint(0, 0), new FlxPoint(100, 100), style2);
		var bolt5:FlxShapeLightning = new FlxShapeLightning(120, 120, new FlxPoint(0, 0), new FlxPoint(100, 100), style2);
		var bolt6:FlxShapeLightning = new FlxShapeLightning(230, 120, new FlxPoint(0, 0), new FlxPoint(100, 100), style2);
		
		add(bolt);
		add(bolt2);
		add(bolt3);
		
		add(bolt4);
		add(bolt5);
		add(bolt6);
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
	
}