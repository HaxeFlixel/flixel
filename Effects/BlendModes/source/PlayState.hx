package;
import flash.display.BlendMode;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.StrIdLabel;
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
	private var _bottom:FlxSprite;
	private var _top:FlxSprite;
	
	private var _dd_blends:FlxUIDropDownMenu;
	private var _step_alpha:FlxUINumericStepper;
	
	override public function create():Void
	{
		super.create();
		var bkg:FlxSprite = new FlxSprite(0, 0);
		bkg.makeGraphic(FlxG.width,FlxG.height,0xFF808080);
		add(bkg);
		
		_bottom = new FlxSprite(0, 0, "assets/bottom.png");
		_top = new FlxSprite(0, 0, "assets/top.png");
		
		_bottom.x = (FlxG.width - _bottom.width) - 10;
		_bottom.y = (FlxG.height - _bottom.height) - 10;
		
		_top.x = _bottom.x;
		_top.y = _bottom.y;
		
		var outline = new FlxSprite(0, 0);
		outline.makeGraphic(cast _top.width + 2,cast _top.height + 2, FlxColor.BLACK);
		
		outline.x = _top.x - 1;
		outline.y = _top.y - 1;
		
		add(outline);
		add(_bottom);
		add(_top);
		
		var list_blends:Array<StrIdLabel> = 
		[
			new StrIdLabel("normal", "Normal"),
			new StrIdLabel("darken", "Darken"),
			new StrIdLabel("multiply", "Multiply"),
			new StrIdLabel("lighten", "Lighten"),
			new StrIdLabel("screen", "Screen"),
			new StrIdLabel("overlay", "Overlay"),
			new StrIdLabel("hardlight", "Hard Light"),
			new StrIdLabel("difference", "Difference"),
			new StrIdLabel("add", "Add"),
			new StrIdLabel("subtract", "Subtract"),
			new StrIdLabel("invert", "Invert")
		];
		
		var label_alpha:FlxText = new FlxText(5, 10, 50, "Alpha:");
		label_alpha.color = 0xFFFFFF;
		label_alpha.setBorderStyle(FlxText.BORDER_OUTLINE_FAST);
		add(label_alpha);
		
		_step_alpha = new FlxUINumericStepper(40, 10, 0.01, 1.00, 0.00, 1.00, 2);
		add(_step_alpha);
		
		var label_blends:FlxText = new FlxText(5, 45, 50, "Blend:");
		label_blends.color = 0xFFFFFF;
		label_blends.setBorderStyle(FlxText.BORDER_OUTLINE_FAST);
		add(label_blends);
		
		_dd_blends = new FlxUIDropDownMenu(40, 40, list_blends, onClickBlend);
		add(_dd_blends);
	}
	
	private function onClickBlend(str:String):Void {
		_top.blend = getBlend(str);
	}

	private function getBlend(str:String):BlendMode {
		switch(str) {
			case "normal": return BlendMode.NORMAL;
			case "darken": return BlendMode.DARKEN;
			case "multiply": return BlendMode.MULTIPLY;
			case "lighten": return BlendMode.LIGHTEN;
			case "screen": return BlendMode.SCREEN;
			case "overlay": return BlendMode.OVERLAY;
			case "hardlight": return BlendMode.HARDLIGHT;
			case "difference": return BlendMode.DIFFERENCE;
			case "add": return BlendMode.ADD;
			case "subtract": return BlendMode.SUBTRACT;
			case "invert": return BlendMode.INVERT;
		}
		return BlendMode.NORMAL;
	}
	
	public override function getEvent(event:String,sender:IFlxUIWidget,data:Dynamic,?params:Dynamic):Void {
		if(event == FlxUINumericStepper.CLICK_EVENT){
			if (sender == _step_alpha) {
				_top.alpha = cast data;
			}
		}
	}

}