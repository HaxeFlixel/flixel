package;
import flash.display.BlendMode;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.StrNameLabel;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * BlendModes demo
 *
 * @author Lars Doucet
 * @link https://github.com/HaxeFlixel/flixel-demos/BlendModes
 */
class PlayState extends FlxUIState
{
	var _bottom:FlxSprite;
	var _top:FlxSprite;
	
	var _step_alpha:FlxUINumericStepper;
	
	var _bottoms:Map<String,FlxSprite>;
	var _tops:Map<String,FlxSprite>;
	
	var _list_blends:Array<String> = null;
	
	override public function create():Void
	{
		super.create();
		
		_list_blends = ["normal", "darken", "multiply", "lighten", "screen", "overlay", "hardlight", "difference", "add", "subtract", "invert"];
		
		var bkg:FlxSprite = new FlxSprite(0, 0);
		bkg.makeGraphic(FlxG.width, FlxG.height, 0xFF808080);
		add(bkg);
		
		var label_alpha:FlxText = new FlxText(2, 2, 50, "Alpha:");
		label_alpha.color = 0xFFFFFF;
		label_alpha.setBorderStyle(OUTLINE_FAST);
		add(label_alpha);
		
		_step_alpha = new FlxUINumericStepper(40, 2, 0.01, 1.00, 0.00, 1.00, 2);
		add(_step_alpha);
		
		makeBlendImages();
	}

	function makeBlendImages():Void
	{
		var xx:Int = 100;
		var yy:Int = 12;
		var column:Int = 0;
		var row:Int = 0;
		
		_bottoms = new Map<String,FlxSprite>();
		_tops = new Map<String,FlxSprite>();
		
		for (str in _list_blends)
		{
			xx = 10 + column * 250;
			yy = 30 + row * 250;
			
			var top:FlxSprite = new FlxSprite(0, 0, "assets/top_small.png");
			var bottom:FlxSprite = new FlxSprite(0, 0, "assets/bottom_small.png");
			
			var outline = new FlxSprite();
			outline.makeGraphic(cast top.width + 2, cast top.height + 2, FlxColor.BLACK);
			
			add(outline);
			add(bottom);
			add(top);
			
			outline.x = cast xx - 1;
			outline.y = cast yy - 1;
			top.x = bottom.x = xx;
			top.y = bottom.y = yy;
			
			top.blend = getBlend(str);
			
			_tops.set(str, top);
			_bottoms.set(str, top);
			
			var label:FlxText = new FlxText(top.x, top.y, cast top.width, str);
			label.y -= label.height;
			label.color = 0xffffff;
			label.setBorderStyle(OUTLINE_FAST);
			add(label);
			
			column++;
			if (column >= 4)
			{
				column = 0;
				row++;
			}
		}
	}
	
	function onClickBlend(str:String):Void
	{
		_top.blend = getBlend(str);
	}

	function getBlend(str:String):BlendMode
	{
		return switch (str)
		{
			case "normal": BlendMode.NORMAL;
			case "darken": BlendMode.DARKEN;
			case "multiply": BlendMode.MULTIPLY;
			case "lighten": BlendMode.LIGHTEN;
			case "screen": BlendMode.SCREEN;
			case "overlay": BlendMode.OVERLAY;
			case "hardlight": BlendMode.HARDLIGHT;
			case "difference": BlendMode.DIFFERENCE;
			case "add": BlendMode.ADD;
			case "subtract": BlendMode.SUBTRACT;
			case "invert": BlendMode.INVERT;
			case _: BlendMode.NORMAL;
		}
	}
	
	public override function getEvent(event:String, sender:Dynamic, data:Dynamic, ?params:Dynamic):Void
	{
		if (event == FlxUINumericStepper.CHANGE_EVENT && sender == _step_alpha)
		{
			for (str in _list_blends)
			{
				var top = _tops.get(str);
				top.alpha = cast data;
			}
		}
	}
}