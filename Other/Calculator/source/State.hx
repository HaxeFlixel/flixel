package;

import flash.display.StageQuality;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.math.FlxVector;
import flixel.math.FlxVelocity;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import StringTools;

/** This state class draws some GUI widgets, and links them to the hscript interpretor, @author @cwkx **/
class State extends FlxState
{
	// Input and output texts, and the interpretor
	var input:FlxUIInputText = new FlxUIInputText();            // Input text
	var outputs:Array<FlxUIText> = new Array<FlxUIText>();      // Output texts
	var interp:Interp = new Interp();                           // Script interpretor
	var graph:FlxSprite;
	
	// Function and example buttons
	var buttons:Array<Array<FlxUIButton>> = new Array<Array<FlxUIButton>>();
	var examples:Array<FlxUIButton> = new Array<FlxUIButton>(); 
	var index:Int = -1;
	
	/** Create GUI widgets and setup script **/
	override public function create():Void
	{
		super.create();
		FlxG.cameras.bgColor = 0xff555555;
		FlxG.scaleMode = new PixelPerfectScaleMode();
		FlxG.stage.quality = StageQuality.BEST;
		
		// Labels
		var labels:FlxText = new FlxText(10, 10, 0, "Input:\n\nString:\n\nInt:\n\nFloat:\n\nHex:\n\nBinary:");
			labels.setFormat("Font", 8, 0xffe1cac2, "left", FlxTextBorderStyle.SHADOW, 0xff1b1b1c);
		add(labels);
		
		// Input text box
		input = new FlxUIInputText();
		input.broadcastToFlxUI = false;
		input.text = "";
		input.setPosition(10 + labels.width, 10);
		input.setFormat("Font", 8, 0xff000000);
		input.textField.width = FlxG.width - input.x - 10;
		add(input);
		
		// Output texts
		for (i in 0 ... 5)
		{
			outputs[i] = new FlxUIText();
			outputs[i].setPosition(10 + labels.width, 26 + 16 * i);
			outputs[i].text = ["String", "Int", "Float", "Hex", "Binary"][i];
			outputs[i].setFormat("Font", 8, 0xffc7e0c1, "left", FlxTextBorderStyle.SHADOW, 0xff1b1b1c);
			
			add(outputs[i]);
		}
		
		// Function buttons
		var btns = [ ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"],
		             ["+", "-", "*", "/", ".", "%", "&", "|", "!", "~"],
		             ["(", ")", "{", "}", "<", ">", "\"", "\\", ";", "="],
		           ];
		for (y in 0 ... btns.length)
		{
			buttons.push(new Array<FlxUIButton>());
			for (x in 0 ... btns[y].length)
			{
				buttons[y].push(new FlxUIButton(10 + x * 23,  FlxG.height - 26 - (btns.length-1 - y) * 18, btns[y][x], function()
				{
					var start = input.text.substring(0, input.caretIndex);
					var end = input.text.substring(input.caretIndex);
					input.text = start + btns[y][x] + end;
					input.hasFocus = true;
					input.caretIndex++;
				}));
				
				buttons[y][x].resize(21, 16);
				buttons[y][x].label.setFormat("Font", 8, 0xff000000, "center");
				add(buttons[y][x]);
			}
		}
		
		// Example buttons
		for (i in 0 ... 3)
		{
			examples[i] = new FlxUIButton(FlxG.width - 76, FlxG.height - 26 - i * 18, ["Prev Example", "Clear Input", "Next Example"][i], function()
			{
				// Example text array
				var txt = [ "1 + 2 << 3",
				            "y = Math.pow(x,3)",
				            "0x10 & 0x110 == 16",
				            "x = []; for (i in [3,9,7]) { x[i] = 7; } x",
				            "FlxPoint.get(0,1).addPoint(FlxPoint.get(-1,3))",
				            "var animal = \"dogs \"; animal + animal.slice(0,2) + \" tricks!\"",
				            "x = \"past\"; if (1 != 2) { x = 3 > 4 ? false : true; }",
				            "Math.sin( FlxG.game.ticks / 1000 ) * 10",
				            "y = Math.sin( FlxG.game.ticks * x * 0.3 ) * 0.7"
				          ];
				
				// Button functions
				if (i == 0) { index--; if (index < 0) index = txt.length -1; }	// Previous
				if (i == 1) { input.text = ""; return;  }                      // Clear
				if (i == 2) { index++; if (index >= txt.length) index = 0; }	// Next
				
				input.text = txt[index];
				input.hasFocus = true;
			});
			
			examples[i].resize(66, 16);
			examples[i].label.setFormat("Font", 8, 0xff000000, "center");
			add(examples[i]);
		}
		
		// Draw graph
		graph = new FlxSprite(10, 108);
		graph.makeGraphic(FlxG.width - 20, 64, 0xff000000);
		add(FlxSpriteUtil.drawRect(graph, 1, 1, graph.width - 2, graph.height - 2, 0xffffffff));
		
		// Set focus
		input.hasFocus = true;
		
		// Bind classes. You can also bind class instances and call their public functions and use their public data
		interp.variables.set("x", 0);
		interp.variables.set("y", 0);
		interp.variables.set("Math", Math);
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("FlxMath", FlxMath);
		interp.variables.set("FlxAngle", FlxAngle);
		interp.variables.set("FlxPoint", FlxPoint);
		interp.variables.set("FlxRandom", FlxRandom);
		interp.variables.set("FlxRect", FlxRect);
		interp.variables.set("FlxVector", FlxVector);
		interp.variables.set("FlxVelocity", FlxVelocity);
	}
	
	/** Update script **/
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Setup parser and expression output
		var parser = new Parser();
		var expr:Expr;
		
		try
		{
			// Try to create an expression from the script and execute it
			expr = parser.parseString(input.text);
			var output:Dynamic = interp.execute(expr);
			
			// Set all the output text colors to default (green)
			for (text in outputs)
				 text.color = 0xffc7e0c1;
			
			// Parse the string. If this fails, it'd be caught outside of this try
			outputs[0].text = "\"" + Std.string(output) + "\"";
			
			// Otherwise try to cast each output to its corresponding type, catching the errors as a red '?' string
			try { outputs[1].text = Std.string(cast(output, Int)); } 				catch (unknown:Dynamic) { outputs[1].color = 0xffe09f9f; outputs[1].text = "?"; }
			try { outputs[2].text = Std.string(cast(output, Float)); } 				catch (unknown:Dynamic) { outputs[2].color = 0xffe09f9f; outputs[2].text = "?"; }
			try { outputs[3].text = "0x" + StringTools.hex(cast(output, Int)); } 	catch (unknown:Dynamic) { outputs[3].color = 0xffe09f9f; outputs[3].text = "?"; }
			try { outputs[4].text = HexToBin(StringTools.hex(cast(output, Int))); } catch (unknown:Dynamic) { outputs[4].color = 0xffe09f9f; outputs[4].text = "?"; }
			
			// Draw graph (naively execute the script 150 times per frame stepping in the y-direction. This has sampling error.)
			FlxSpriteUtil.drawRect(graph, 0, 0, graph.width, graph.height, 0xffffffff, { thickness:2, color:0xff000000});
			FlxSpriteUtil.drawLine(graph, graph.width / 2, 1, graph.width / 2, graph.height - 1, { thickness:1, color:0xff999999 } );
			FlxSpriteUtil.drawLine(graph, 1, graph.height/2, graph.width -1, graph.height/2, { thickness:1, color:0xff999999 } );
			if (input.text.indexOf("y") >= 0)
			for (x in 0 ... 150+1)
			{
				var prvY:Float = (interp.variables.get("y") * 0.5 + 1.0) * graph.height;
				interp.variables.set("x", (x / 150) * 2.0 - 1.0);
				interp.execute(expr);
				
				if (x != 0)
					FlxSpriteUtil.drawLine(graph, graph.width * ((x - 1) / 150), (graph.height - prvY) + graph.height / 2, 
					                       graph.width * (x / 150), (graph.height - (interp.variables.get("y") * 0.5 + 1.0) * graph.height) + graph.height / 2, 
					                       { thickness:1, color:0xff566153});
			}
		}
		
		// Catch error messages into first output text
		catch (unknown:Dynamic)
		{
			outputs[0].color = 0xffe09f9f;
			outputs[0].text = Std.string(unknown);
		}
	}
	
	/** Convers hex string to binary string **/
	private function HexToBin(hex:String):String
	{
		var out:String = "";
		
		for (i in 0 ... hex.length)
			out += ["0000", "0001", "0010", "0011", "0100", "0101", "0110", "0111",
			        "1000", "1001", "1010", "1011", "1100", "1101", "1110", "1111"][Std.parseInt("0x" + hex.charAt(i))];
		
		while (out.charAt(0) == "0")
			out = out.substring(1);	// Remove leading zeros
		
		return out == "" ? "0" : out; // Make sure a 0 is drawn if empty
	}
}
