package;

import flash.display.BitmapData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileCircle;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileSquare;
import flixel.addons.transition.TransitionData;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIRadioGroup;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUITypedButton;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxUIState
{
	static var initialized:Bool = false;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		_xml_id = "ui";
		super.create();
		
		init();
	}
	
	private function init():Void
	{
		if (initialized == false)
		{
			initialized = true;
			
			//If this is the first time we've run the program, we initialize the TransitionData
			
			//When we set the default static transIn/transOut values, on construction all 
			//FlxTransitionableStates will use those values if their own transIn/transOut states are null
			FlxTransitionableState.defaultTransIn = new TransitionData();
			FlxTransitionableState.defaultTransOut = new TransitionData();
			FlxTransitionableState.defaultTransIn.tileData = { asset:GraphicTransTileDiamond, width:32, height:32 };
			FlxTransitionableState.defaultTransOut.tileData = { asset:GraphicTransTileDiamond, width:32, height:32 };
			
			//Of course, this state has already been constructed, so we need to set a transOut value for it right now:
			transOut = FlxTransitionableState.defaultTransOut;
		}
		
		//Now we just have the UI synchronize with the starting values:
		matchTransitionData();
		matchUI(false);
	}
	
	private function matchUI(matchData:Bool=true):Void
	{
		var in_duration:FlxUINumericStepper = cast _ui.getAsset("in_duration");
		var in_type:FlxUIRadioGroup = cast _ui.getAsset("in_type");
		var in_tile:FlxUIRadioGroup = cast _ui.getAsset("in_tile");
		var in_tile_text:FlxUIText = cast _ui.getAsset("in_tile_text");
		var in_color:FlxUIRadioGroup = cast _ui.getAsset("in_color");
		var in_dir:FlxUIRadioGroup = cast _ui.getAsset("in_dir");
		
		var out_duration:FlxUINumericStepper = cast _ui.getAsset("out_duration");
		var out_type:FlxUIRadioGroup = cast _ui.getAsset("out_type");
		var out_tile:FlxUIRadioGroup = cast _ui.getAsset("out_tile");
		var out_tile_text:FlxUIText = cast _ui.getAsset("out_tile_text");
		var out_color:FlxUIRadioGroup = cast _ui.getAsset("out_color");
		var out_dir:FlxUIRadioGroup = cast _ui.getAsset("out_dir");
		
		FlxTransitionableState.defaultTransIn.color = FlxColor.fromString(in_color.selectedId);
		FlxTransitionableState.defaultTransIn.type = cast in_type.selectedId;
		setDirectionFromStr(in_dir.selectedId, FlxTransitionableState.defaultTransIn.direction);
		FlxTransitionableState.defaultTransIn.duration = in_duration.value;
		FlxTransitionableState.defaultTransIn.tileData.asset = getDefaultAsset(in_tile.selectedId);
		
		FlxTransitionableState.defaultTransOut.color = FlxColor.fromString(out_color.selectedId);
		FlxTransitionableState.defaultTransOut.type = cast out_type.selectedId;
		setDirectionFromStr(out_dir.selectedId, FlxTransitionableState.defaultTransOut.direction);
		FlxTransitionableState.defaultTransOut.duration = out_duration.value;
		FlxTransitionableState.defaultTransOut.tileData.asset = getDefaultAsset(out_tile.selectedId);
		
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		
		if (matchData)
		{
			matchTransitionData();
		}
	}
	
	private function matchTransitionData():Void
	{
		var in_duration:FlxUINumericStepper = cast _ui.getAsset("in_duration");
		var in_type:FlxUIRadioGroup = cast _ui.getAsset("in_type");
		var in_tile:FlxUIRadioGroup = cast _ui.getAsset("in_tile");
		var in_tile_text:FlxUIText = cast _ui.getAsset("in_tile_text");
		var in_color:FlxUIRadioGroup = cast _ui.getAsset("in_color");
		var in_dir:FlxUIRadioGroup = cast _ui.getAsset("in_dir");
		
		var out_duration:FlxUINumericStepper = cast _ui.getAsset("out_duration");
		var out_type:FlxUIRadioGroup = cast _ui.getAsset("out_type");
		var out_tile:FlxUIRadioGroup = cast _ui.getAsset("out_tile");
		var out_tile_text:FlxUIText = cast _ui.getAsset("out_tile_text");
		var out_color:FlxUIRadioGroup = cast _ui.getAsset("out_color");
		var out_dir:FlxUIRadioGroup = cast _ui.getAsset("out_dir");
		
		in_duration.value = FlxTransitionableState.defaultTransIn.duration;
		in_type.selectedId = cast FlxTransitionableState.defaultTransIn.type;
		if (FlxTransitionableState.defaultTransIn.type == TILES)
		{
			in_tile_text.visible = in_tile.visible = true;
			var intileasset:Class<BitmapData> = cast FlxTransitionableState.defaultTransIn.tileData.asset;
			in_tile.selectedId = getDefaultAssetStr(intileasset);
		}
		else
		{
			in_tile_text.visible = in_tile.visible = false;
		}
		in_color.selectedId = switch(FlxTransitionableState.defaultTransIn.color)
		{
			case FlxColor.RED: "red";
			case FlxColor.WHITE: "white";
			case FlxColor.BLUE: "blue";
			case FlxColor.BLACK: "black";
			case FlxColor.GREEN: "green";
			case _: "black";
		}
		in_dir.selectedId = getDirection(cast FlxTransitionableState.defaultTransIn.direction.x, cast FlxTransitionableState.defaultTransIn.direction.y);
		
		out_duration.value = FlxTransitionableState.defaultTransOut.duration;
		out_type.selectedId = cast FlxTransitionableState.defaultTransOut.type;
		if (FlxTransitionableState.defaultTransOut.type == TILES)
		{
			out_tile_text.visible = out_tile.visible = true;
			var outtileasset:Class<BitmapData> = cast FlxTransitionableState.defaultTransOut.tileData.asset;
			out_tile.selectedId = getDefaultAssetStr(outtileasset);
		}
		else
		{
			out_tile_text.visible = out_tile.visible = false;
		}
		out_color.selectedId = switch(FlxTransitionableState.defaultTransOut.color)
		{
			case FlxColor.RED: "red";
			case FlxColor.WHITE: "white";
			case FlxColor.BLUE: "blue";
			case FlxColor.BLACK: "black";
			case FlxColor.GREEN: "green";
			case _: "black";
		}
		out_dir.selectedId = getDirection(cast FlxTransitionableState.defaultTransOut.direction.x, cast FlxTransitionableState.defaultTransOut.direction.y);
		
	}
	
	private function getDefaultAssetStr(c:Class<BitmapData>):String
	{
		return switch(c)
		{
			case GraphicTransTileCircle: "circle";
			case GraphicTransTileSquare: "square";
			case GraphicTransTileDiamond, _: "diamond";
		}
	}
	
	private function getDefaultAsset(str):Class<BitmapData>
	{
		return switch(str)
		{
			case "circle": GraphicTransTileCircle;
			case "square": GraphicTransTileSquare;
			case "diamond", _: GraphicTransTileDiamond;
		}
	}
	
	private function getDirection(ix:Int, iy:Int):String
	{
		if (ix < 0)
		{
			if (iy == 0) return "w";
			if (iy > 0) return "sw";
			if (iy < 0) return "nw";
		}
		else if (ix > 0)
		{
			if (iy == 0) return "e";
			if (iy > 0) return "se";
			if (iy < 0) return "ne";
		}
		else if (ix == 0)
		{
			if (iy > 0) return "s";
			if (iy < 0) return "n";
		}
		return "center";
	}
	
	private function setDirectionFromStr(str:String,p:FlxPoint=null):FlxPoint
	{
		if (p == null)
		{
			p = new FlxPoint();
		}
		switch(str)
		{
			case "n": p.set(0, -1);
			case "s": p.set(0, 1);
			case "w": p.set(-1, 0);
			case "e": p.set(1, 0);
			case "nw": p.set( -1, -1);
			case "ne": p.set(1, -1);
			case "sw":p.set( -1, 1);
			case "se":p.set(1, 1);
			default: p.set(0, 0);
		}
		return p;
	}
	
	private function transition():Void
	{
		FlxG.switchState(new MenuStateB());
	}
	
	public override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		switch(id)
		{
			case FlxUITypedButton.CLICK_EVENT:
				var butt:FlxUIButton = cast sender;
				if (butt.id == "transition")
				{
					matchUI();
					transition();
				}
			case FlxUIRadioGroup.CLICK_EVENT:
				var radio:FlxUIRadioGroup = cast sender;
				if (!radio.visible) return;
				matchUI();
			case FlxUINumericStepper.CHANGE_EVENT:
				matchUI();
		}
	}
}