package;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#else
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

/**
 * @author Joe Williamson (JoeCreates)
 */
class DemoState extends FlxState
{
	public var creationPanel:DemoPanel;
	public var manipulationPanel:DemoPanel;
	public var presetsPanel:DemoPanel;
	public var gradientsPanel:DemoPanel;
	public var harmoniesPanel:DemoPanel;

	public var currentDemoText:FlxText;
	public var pageText:FlxText;
	public var nextButton:FlxButton;
	public var prevButton:FlxButton;

	public var panels:FlxTypedGroup<DemoPanel>;
	public var currentPanelIndex:Int;

	public var colorInfoText:FlxText;

	override public function create():Void
	{
		panels = new FlxTypedGroup<DemoPanel>();
		add(panels);

		currentPanelIndex = 0;

		creationPanel = new DemoPanel("FlxColor Creation");
		panels.add(creationPanel);
		manipulationPanel = new DemoPanel("FlxColor Properties");
		panels.add(manipulationPanel);
		presetsPanel = new DemoPanel("Presets");
		panels.add(presetsPanel);
		gradientsPanel = new DemoPanel("Gradients");
		panels.add(gradientsPanel);
		harmoniesPanel = new DemoPanel("Harmonies");
		panels.add(harmoniesPanel);

		for (panel in panels)
		{
			panel.x = (panels.members.indexOf(panel) - currentPanelIndex) * FlxG.width;
		}

		nextButton = new FlxButton(0, 0, "Next", nextPanel);
		nextButton.setPosition(FlxG.width - nextButton.width, FlxG.height - nextButton.height);
		add(nextButton);

		prevButton = new FlxButton(0, 0, "Previous", previousPanel);
		prevButton.setPosition(0, FlxG.height - nextButton.height);
		add(prevButton);

		pageText = new FlxText(0, FlxG.height - 14, FlxG.width, "Page");
		pageText.alignment = CENTER;
		add(pageText);
		changePanel();

		var txt:FlxText;
		var panel:DemoPanel;

		//-- Creation --
		panel = creationPanel;

		txt = new FlxText(4, 30, FlxG.width - 8, "", 12);
		txt.wordWrap = true;
		txt.font = "fairfax";
		txt.text = "FlxColors are interchangeable with Ints, so you may do this:\n\n"
			+ "var myColor:FlxColor = 0xff123456;\n\n"
			+ "Or use static methods (with optional alpha params):\n\n"
			+ "FlxColor.fromRGB(220, 100, 150);\n\n"
			+ "FlxColor.fromRGBFloat(0.8, 0.5, 0.3);\n\n"
			+ "FlxColor.fromHSB(120, 0.6, 0.9);\n\n"
			+ "FlxColor.fromHSL(120, 0.6, 0.9);\n\n"
			+ "FlxColor.fromCMYK(0.8, 0.6, 0.1, 0.5)";
		panel.add(txt);

		var i = 0;
		for (c in [
			0xff123456,
			null,
			FlxColor.fromRGB(220, 100, 150),
			FlxColor.fromRGBFloat(0.8, 0.5, 0.3),
			FlxColor.fromHSB(120, 0.6, 0.9),
			FlxColor.fromHSL(120, 0.6, 0.9),
			FlxColor.fromCMYK(0.8, 0.6, 0.1, 0.5)
		])
		{
			if (c != null)
				panel.add(makeSprite(240, 50 + i * 24, c));
			i++;
		}

		//-- Properties --
		panel = manipulationPanel;

		txt = new FlxText(2, 25, FlxG.width - 4, "You may get and set the following properties of a FlxColor:-", 12);
		txt.font = "fairfax";
		panel.add(txt);

		var myColor:FlxColor = FlxG.random.color();
		var colorSpr = makeSprite(60, 46, myColor, FlxG.width - 120, 20);
		panel.add(colorSpr);

		var sliders = new Array<PropertySlider>();

		var colX = function(column:Int)
		{
			return 5 + column * 100;
		}
		var rowY = function(row:Int)
		{
			return 72 + row * 36;
		}

		Macro.makeSlider(colX(0), rowY(0), "red", 0, 255, 1, 10);
		Macro.makeSlider(colX(0), rowY(1), "green", 0, 255, 1, 10);
		Macro.makeSlider(colX(0), rowY(2), "blue", 0, 255, 1, 10);
		Macro.makeSlider(colX(0), rowY(3), "alpha", 0, 255, 1, 10);

		Macro.makeSlider(colX(1), rowY(0), "redFloat", 0, 1, 0.01, 0.1);
		Macro.makeSlider(colX(1), rowY(1), "greenFloat", 0, 1, 0.01, 0.1);
		Macro.makeSlider(colX(1), rowY(2), "blueFloat", 0, 1, 0.01, 0.1);
		Macro.makeSlider(colX(1), rowY(3), "alphaFloat", 0, 1, 0.01, 0.1);

		Macro.makeSlider(colX(2), rowY(0), "hue", 0, 360, 5, 20, 0);
		Macro.makeSlider(colX(2), rowY(1), "saturation", 0, 1, 0.01, 0.1);
		Macro.makeSlider(colX(2), rowY(2), "brightness", 0, 1, 0.01, 0.1);
		Macro.makeSlider(colX(2), rowY(3), "lightness", 0, 1, 0.01, 0.1);

		Macro.makeSlider(colX(3), rowY(0), "cyan", 0, 1, 0.01, 0.1);
		Macro.makeSlider(colX(3), rowY(1), "magenta", 0, 1, 0.01, 0.1);
		Macro.makeSlider(colX(3), rowY(2), "yellow", 0, 1, 0.01, 0.1);
		Macro.makeSlider(colX(3), rowY(3), "black", 0, 1, 0.01, 0.1);

		for (s in sliders)
			s.updateValue(s);

		//-- Presets --
		panel = presetsPanel;

		txt = new FlxText(2, 25, FlxG.width - 4, "The following static preset colors are available on FlxColor:", 12);
		txt.font = "fairfax";
		panel.add(txt);

		var presetHeight = 15;
		var presetWidth = 100;
		var maxY = FlxG.height - presetHeight - 65;
		var startX = FlxG.width / 6;
		var startY = 100;
		var currentX = startX;
		var currentY = startY;

		Macro.makePresetSprite("TRANSPARENT");
		Macro.makePresetSprite("WHITE");
		Macro.makePresetSprite("GRAY");
		Macro.makePresetSprite("BLACK");

		Macro.makePresetSprite("GREEN");
		Macro.makePresetSprite("LIME");
		Macro.makePresetSprite("YELLOW");
		Macro.makePresetSprite("ORANGE");
		Macro.makePresetSprite("RED");
		Macro.makePresetSprite("PURPLE");
		Macro.makePresetSprite("BLUE");
		Macro.makePresetSprite("BROWN");
		Macro.makePresetSprite("PINK");
		Macro.makePresetSprite("MAGENTA");
		Macro.makePresetSprite("CYAN");

		//-- Gradients --
		panel = gradientsPanel;

		var c1 = FlxColor.RED;
		var c2 = FlxColor.GREEN;

		txt = new FlxText(4, 30, FlxG.width - 8, "", 12);
		txt.wordWrap = true;
		txt.font = "fairfax";
		txt.text = "var c1 = FlxColor.RED;\n"
			+ "var c2 = FlxColor.GREEN;\n\n"
			+ "// Interpolate by factor 0.5\nFlxColor.interpolate(c1, c2, 0.5);\n\n"
			+ "FlxColor.gradient(c1, c2, 20); // Returns array of colors\n\n\n\n"
			+ "FlxColor.gradient(c1, c2, 20, FlxEase.quadIn); // Easing";
		panel.add(txt);

		panel.add(makeSprite(250, 32, c1, 20, 11));
		panel.add(makeSprite(250, 44, c2, 20, 11));
		panel.add(makeSprite(250, 68, FlxColor.interpolate(c1, c2, 0.5)));

		var i = 0;
		for (c in FlxColor.gradient(c1, c2, 20))
		{
			panel.add(makeSprite(10 + 17 * i, 120, c, 17, 14));
			i++;
		}
		var i = 0;
		for (c in FlxColor.gradient(c1, c2, 20, FlxEase.quadIn))
		{
			panel.add(makeSprite(10 + 17 * i, 168, c, 17, 14));
			i++;
		}

		//-- Harmonies --
		panel = harmoniesPanel;

		var myColor = FlxColor.RED;
		var complementHarmony:FlxColor = myColor.getComplementHarmony();
		var splitComplementHarmony:Harmony = myColor.getSplitComplementHarmony();
		var analogousHarmony:Harmony = myColor.getAnalogousHarmony();
		var triadicHarmony:TriadicHarmony = myColor.getTriadicHarmony();
		var lineHeight = 12;

		panel.add(makeSprite(240, 28, myColor));

		panel.add(makeSprite(240, 28 + lineHeight * 2, complementHarmony));

		panel.add(makeSprite(240, 28 + lineHeight * 4, splitComplementHarmony.original));
		panel.add(makeSprite(262, 28 + lineHeight * 4, splitComplementHarmony.warmer));
		panel.add(makeSprite(284, 28 + lineHeight * 4, splitComplementHarmony.colder));

		panel.add(makeSprite(240, 28 + lineHeight * 6, analogousHarmony.original));
		panel.add(makeSprite(262, 28 + lineHeight * 6, analogousHarmony.warmer));
		panel.add(makeSprite(284, 28 + lineHeight * 6, analogousHarmony.colder));

		panel.add(makeSprite(240, 28 + lineHeight * 8, triadicHarmony.color1));
		panel.add(makeSprite(262, 28 + lineHeight * 8, triadicHarmony.color2));
		panel.add(makeSprite(284, 28 + lineHeight * 8, triadicHarmony.color3));

		txt = new FlxText(4, 30, FlxG.width - 8, "", 12);
		txt.wordWrap = true;
		txt.font = "fairfax";
		txt.text = "var myColor = FlxColor.RED;\n\n" + "myColor.getComplementHarmony();\n\n" + "myColor.getSplitComplementHarmony();\n\n"
			+ "myColor.getAnalogousHarmony();\n\n" + "myColor.getTriadicHarmony();\n\n";
		panel.add(txt);
	}

	public function makeSprite(x:Int = 0, y:Int = 0, color:FlxColor, width:Int = 20, height:Int = 20):FlxSprite
	{
		var spr = new FlxSprite(x, y);
		spr.makeGraphic(width, height, color, true);
		return spr;
	}

	public function nextPanel():Void
	{
		currentPanelIndex = FlxMath.wrap(currentPanelIndex + 1, 0, panels.length - 1);
		changePanel();
	}

	public function previousPanel():Void
	{
		currentPanelIndex = FlxMath.wrap(currentPanelIndex - 1, 0, panels.length - 1);
		changePanel();
	}

	public function changePanel():Void
	{
		pageText.text = "Page " + (currentPanelIndex + 1) + " / " + panels.length;
		for (panel in panels)
		{
			FlxTween.tween(panel, {x: (panels.members.indexOf(panel) - currentPanelIndex) * FlxG.width}, 0.7, {ease: FlxEase.expoOut});
		}
	}
}
#end

private class Macro
{
	macro public static function makeSlider(x:Expr, y:Expr, value:String, min:Float, max:Float, smallDelta:Float, bigDelta:Float, decimalPlaces:Int = 2):Expr
	{
		var assignValue:Expr;
		switch (Context.typeof(macro myColor.$value))
		{
			case TAbstract(r, _) if (r.get().name == "Int"):
				assignValue = macro myColor.$value = Std.int(s.value);
			default:
				assignValue = macro myColor.$value = s.value;
		}
		return macro
		{
			var slider = new PropertySlider($v{value}, $v{smallDelta}, $v{bigDelta}, $v{min}, $v{max});
			sliders.push(slider);
			slider.setPosition($x, $y);
			slider.decimalPlaces = $v{decimalPlaces};
			slider.updateValue = function(s:PropertySlider)
			{
				s.value = myColor.$value;
			};
			slider.onChange = function(s:PropertySlider)
			{
				$assignValue;
				colorSpr.makeGraphic(FlxG.width - 120, 20, myColor, true);
				for (s in sliders)
				{
					s.updateValue(s);
				}
			};
			panel.add(slider);
		}
	}

	macro public static function makePresetSprite(name:String):Expr
	{
		return macro
		{
			var presetSpr = new FlxSpriteGroup();
			presetSpr.add(makeSprite(0, 0, FlxColor.$name, 14, 14));
			var presetTxt = new FlxText(21, 1, 0, $v{name}, 12);
			presetTxt.font = "fairfax";
			presetSpr.add(presetTxt);
			presetSpr.setPosition(currentX, currentY);
			currentY += presetHeight;
			if (currentY > maxY)
			{
				currentY = startY;
				currentX += presetWidth;
			}
			panel.add(presetSpr);
		}
	}
}
