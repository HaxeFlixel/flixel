import flixel.addons.ui.FlxUI;
import flixel.addons.ui.IEventGetter;
import flixel.addons.ui.U;
import haxe.xml.Fast;
import flash.geom.Point;
import nme.Lib;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;

/**
 * ...
 * @author Lars Doucet
 */

class SaveSlot extends FlxUI
{
	
	//var data : PartySaveData;
	//var prog : GameProgress;
	//var prog_plus : GameProgress;
	//var bonus : BonusProgress;
	//var bonus_plus : BonusProgress;
	//var journal : JournalProgress;
	/*var back : FlxSprite;
	var shadow : FlxSprite;
	var group_icons : FlxGroup;
	var text_name : FlxText;
	var text_time : FlxText;
	var text_date : FlxText;
	var text_party : FlxText;
	var text_act : FlxText;
	var text_loc : FlxText;
	var group_icon_texts : FlxGroup;
	var butt_load : FlxButtonPlusX;
	var butt_plus : FlxButtonPlusX;
	var butt_del : FlxButtonPlusX;
	var butt_test : FlxButtonPlusX;
	var butt_import : FlxButtonPlusX;
	var butt_export : FlxButtonPlusX;*/
	/*var star_blue : FlxSprite;
	var star_gold : FlxSprite;
	var star_blue_text : FlxText;
	var star_gold_text : FlxText;
	var star_easy : FlxSprite;
	var star_normal : FlxSprite;
	var star_hard : FlxSprite;*/
	
	//var ptr_state : State_SaveMenu;
	//var ptr_state_demo : FlxState;// StateDemoOver;
	
	private var ptr:IEventGetter;
	
	public var valid : Bool;
	
	
	public function new(data:Fast, definition:Fast = null, _ptr:Dynamic = null) {
		super(null, _ptr);		
		if (_ptr != null) {
			if (Std.is(_ptr, FlxUI)) {
				var ui:FlxUI = cast _ptr;
				_ptr_tongue = ui.tongue;
			}
		}
		loadStuff(data, definition, _ptr);
		valid = true;
		FlxG.log.add("SaveSlot(" + str_id + "" + _ptr + ")");
		/*		
		var a : Array<Dynamic> = U.readSaveObjects(_id, true);
		if(a != null && a.length != 0 && a[0] != null)  {
			data = cast((a[0]), PartySaveData);
			prog = cast((a[1]), GameProgress);
			bonus = cast((a[2]), BonusProgress);
			journal = cast((a[3]), JournalProgress);
			//new game plus progress:
			prog_plus = cast((a[4]), GameProgress);
			bonus_plus = cast((a[5]), BonusProgress);
		}
		if(Std.is(_ptr, State_SaveMenu))  {
			ptr_state = _ptr;
		}

		else  {
			ptr_state_demo = _ptr;
		}*/

		init();
	}

	public function loadStuff(data:Fast, definition:Fast, _ptr:Dynamic):Void {		
		load(definition);
		str_id = U.xml_str(data.x,"id");
		instant_update = true;
	}
	
	public override function update():Void {
		super.update();
	}
		
	
	
	/*public function getStars(plus : Bool = false) : Point{
		if(plus)  {
			if(prog_plus != null)  {
				return prog_plus.countStarsAchieved();
			}
		}

		else  {
			if(prog != null)  {
				return prog.countStarsAchieved();
			}
		}

		return new Point(0, 0);
	}

	public function getSaveObjects() : Array<Dynamic> {
		return [data, prog, bonus, journal, prog_plus, bonus_plus];
	}

	override public function destroy() : Void {
		ptr_state = null;
		ptr_state_demo = null;
		super.destroy();
		var arr : Array<Dynamic> = ["shadow", "back", "text_name", "text_time", "text_date", "text_party", "text_act", "text_loc", "butt_load", "butt_del", "butt_test", "butt_import", "butt_export"];
		for(str in arr){
		// AS3HX WARNING could not determine type for var: str exp: EIdent(arr) type: Array<Dynamic>
			if(this[str])  {
				cast((this[str]), FlxObject).destroy();
				this[str] = null;
			}
		}

		if(group_icon_texts != null)  {
			group_icon_texts.destroy();
			group_icon_texts = null;
		}
		if(group_icons != null)  {
			group_icons.destroy();
			group_icons = null;
		}
		data = null;
		prog = null;
		back = null;
		journal = null;
		prog_plus = null;
		bonus = null;
		bonus_plus = null;
		text_name = null;
		text_time = null;
		text_date = null;
		text_party = null;
		text_act = null;
		text_loc = null;
		group_icons = null;
		group_icon_texts = null;
		butt_load = null;
		butt_plus = null;
		butt_del = null;
		butt_export = null;
		butt_import = null;
		butt_test = null;
		ptr_state = null;
		ptr_state_demo = null;
		star_blue = null;
		star_gold = null;
		star_blue_text = null;
		star_gold_text = null;
		star_easy = null;
		star_hard = null;
		star_normal = null;
	}

	public function isEmpty() : Bool {
		if(prog != null)  {
			if(data == null)  {
				return true;
			}

			else if(data.mcguffin == null)  {
				return true;
			}

			else if(data.mcguffin._charClass == null)  {
				return true;
			}
			return false;
		}
		return true;
	}*/

	
	private override function _onClickButton(params:Dynamic = null):Void {
		if (Std.is(params, String)) {
			var str:String = cast(params, String);
			switch(str) {
				case "play": onPress();
				case "play+": onPlus();
				case "export": onExport();
				case "import": onImport();
				case "delete": onDel();
			}
		}
	}
	
	function init() : Void {
				
		/*
		
		var exists : Bool = false;
		var need_delete : Bool = false;
		if(prog != null)  {
			exists = true;
			if(data == null)  {
				need_delete = true;
				exists = false;
			}

			else if(data.mcguffin == null)  {
				need_delete = true;
				exists = false;
			}

			else if(data.mcguffin._charClass == null)  {
				need_delete = true;
				exists = false;
			}
		}
		if(exists)  {
			var allow_newgameplus : Bool = false;
			var newgameplus_exists : Bool = false;
			if(Main.GOLD && !Main.DEMO_MODE)  {
				var highest_pass : Int = prog.checkGameBeaten(false);
				if(highest_pass > 0)  {
					//we have beaten the game
					allow_newgameplus = true;
				}
				//Check if a newgame_plus already exists
				if(prog_plus.visiblePearls.length >= 1)  {
					newgameplus_exists = true;
				}
				//Always allow a newgameplus if the data for it exists
				if(!allow_newgameplus && newgameplus_exists)  {
					allow_newgameplus = true;
				}
			}
			if(Main.GOLD && allow_newgameplus)  {
				butt_plus = new FlxButtonX(578, 35, onPlus);
				if(newgameplus_exists)  {
					butt_plus.loadGraphic(U.FS(U.gfx("button_blue_skinny", "UI", "buttons")), U.FS(U.gfx("button_blue_skinny_over", "UI", "buttons")));
					butt_plus.setSimpleLabel("Play +", 10, 0xffffff, true, 1, -2);
				}

				else  {
					butt_plus.loadGraphic(U.FS(U.gfx("button_gold_skinny_up", "UI", "buttons")), U.FS(U.gfx("button_gold_skinny_over", "UI", "buttons")));
					butt_plus.setSimpleLabel("New Game +", 10, 0xffffff, true, 1, -2);
				}

				butt_load.loadGraphic(U.FS(U.gfx("button_blue_skinny", "UI", "buttons")), U.FS(U.gfx("button_blue_skinny_over", "UI", "buttons")));
				butt_load.setSimpleLabel("Play", 10, 0xffffff, true, 1, -2);
			}

			else  {
				butt_load.loadGraphic(U.FS(U.gfx("button_blue_up", "UI", "buttons")), U.FS(U.gfx("button_blue_over", "UI", "buttons")));
				butt_load.setSimpleLabel("Play", 13);
			}

			if(!Main.DEMO_MODE)  {
				// AS3HX WARNING namespace modifier CONFIG::debug 
				 {
					butt_test.visible = false;
				}

			}
			butt_del.visible = true;
			butt_export.visible = true;
			butt_import.visible = false;
		}

		else  {
			butt_load.loadGraphic(U.FS(U.gfx("button_gold_up", "UI", "buttons")), U.FS(U.gfx("button_gold_over", "UI", "buttons")));
			butt_load.setSimpleLabel("New Game", 13);
			// AS3HX WARNING namespace modifier CONFIG::debug 
			 {
				if(!Main.DEMO_MODE)  {
					butt_test.visible = true;
				}
			}

			butt_del.visible = false;
			butt_export.visible = false;
			butt_import.visible = true;
		}

		butt_export.loadGraphic(U.FS(U.gfx("button_gold_skinny_up", "UI", "buttons")), U.FS(U.gfx("button_gold_skinny_over", "UI", "buttons")));
		butt_export.setSimpleLabel("Export", 10, 0xffffff, true, 1, -2);
		butt_del.loadGraphic(U.FS(U.gfx("button_red_skinny_up", "UI", "buttons")), U.FS(U.gfx("button_red_skinny_over", "UI", "buttons")));
		butt_del.setSimpleLabel("Delete", 10, 0xffffff, true, 1, -2);
		butt_import.loadGraphic(U.FS(U.gfx("button_gold_skinny_up", "UI", "buttons")), U.FS(U.gfx("button_gold_skinny_over", "UI", "buttons")));
		butt_import.setSimpleLabel("Import", 10, 0xffffff, true, 1, -2);
		// AS3HX WARNING namespace modifier CONFIG::debug 
		 {
			if(!Main.DEMO_MODE)  {
				butt_test.loadGraphic(U.FS(U.gfx("button_gold_skinny_up", "UI", "buttons")), U.FS(U.gfx("button_gold_skinny_over", "UI", "buttons")));
				butt_test.setSimpleLabel("Test", 10, 0xffffff, true, 1, -2);
			}
		}

		var border : Int = 8;
		var space_y : Float = (back.height - (border * 2) - (butt_load.height + butt_export.height + butt_del.height)) / 4;
		if(butt_plus != null)  {
			space_y = (back.height - (border * 2) - (butt_load.height + butt_export.height + butt_del.height + butt_plus.height)) / 5;
		}
		butt_load.reset(back.width - butt_load.width - space_y - border, border + space_y);
		var lasty : Float = border + space_y + butt_load.height;
		if(butt_plus != null)  {
			butt_plus.reset(butt_load.x, lasty + space_y);
			lasty = butt_plus.y + butt_plus.height;
		}
		butt_import.reset(butt_load.x, lasty + space_y);
		if(!Main.DEMO_MODE)  {
			butt_export.reset(butt_load.x, butt_import.y);
			butt_del.reset(butt_load.x, butt_import.y + butt_import.height + space_y);
		}

		else  {
			butt_export.reset(butt_load.x, butt_load.y + butt_load.height + space_y);
			butt_del.reset(butt_load.x, butt_export.y + butt_export.height + space_y);
		}

		// AS3HX WARNING namespace modifier CONFIG::debug 
		 {
			if(!Main.DEMO_MODE)  {
				butt_test.reset(butt_del.x, butt_del.y);
				add(butt_test);
			}
		}

		add(butt_import);
		add(butt_load);
		add(butt_del);
		add(butt_export);
		if(butt_plus != null)  {
			add(butt_plus);
		}
		if(exists)  {
			var icon : BasicEntity = Main.factory_defender.getFastIconFromStr(CharacterClass.CLASS_MCGUFFIN, true, true);
			//icon.scale = new FlxPoint(2, 2);
			icon.y = back.y + back.height - icon.height - 8;
			icon.x = -30;
			group_icons.add(icon);
			text_name = new FlxTextX(icon.x + (icon.width - 40), 8, 200, "VERYLONGNAME");
			text_name.setFormat("Verdana", 18, 0xffffff, "left", 1);
			text_name.dropShadow = true;
			text_name.bold = true;
			text_name.text = data.mcguffin._name + "\nLevel " + data.mcguffin._level.toString();
			add(text_name);
			text_time = new FlxTextX(text_name.x, text_name.y + 53, 400, "ff:00");
			text_time.setFormat("Verdana_14pt_st", 14, 0xffffff, "left", 1);
			text_time.dropShadow = true;
			text_time.bold = true;
			var secs : Int = prog.secPlayed;
			if(prog_plus != null)  {
				secs += prog.secPlayed;
			}
			var mins : Int = secs / (60);
			var hours : Int = mins / (60);
			mins = mins % 60;
			var hour_str : String = hours.toString();
			hour_str += " Hour";
			if(hours != 1) 
				hour_str += "s";
			hour_str += ", ";
			if(hours == 0)  {
				hour_str = "";
			}
			var min_str : String = mins.toString();
			min_str += " Min";
			text_time.text = hour_str + min_str;
			add(text_time);
			text_date = new FlxTextX(text_name.x, text_time.y + 17, 300, "date/date/date");
			text_date.setFormat("Verdana_14pt_st", 14, 0xffffff, "left", 1);
			text_date.dropShadow = true;
			text_date.bold = true;
			text_date.text = prog.timeLastSaved.toDateString();
			add(text_date);
			showParty();
			//CONFIG::fullversion{
			showBonus();
		}
		if(need_delete)  {
			cleanSlot();
		}
		if(ptr_state == null && ptr_state_demo != null)  {
			if(butt_load != null)  {
				butt_load.visible = false;
			}
			if(butt_import != null)  {
				butt_import.visible = false;
			}
			if(butt_del != null)  {
				butt_del.visible = false;
			}
			if(butt_test != null)  {
				butt_test.visible = false;
			}
			if(butt_plus != null)  {
				butt_plus.visible = false;
			}
		}
		if(Main.DEMO_MODE)  {
			butt_import.visible = false;
			// AS3HX WARNING namespace modifier CONFIG::debug 
			 {
				butt_import.visible = (butt_export.visible == false);
			}

		}
		*/
	}

	/*
	function showCompletion() : Void {
		var highest_pass : Int = prog.checkGameBeaten(false);
		var highest_perfect : Int = prog.checkGameBeaten(true);
		var star_e : Class<Dynamic> = U.gfx("star_pattern", "WorldMap");
		var star_n : Class<Dynamic> = U.gfx("star_pattern", "WorldMap");
		var star_h : Class<Dynamic> = U.gfx("star_pattern", "WorldMap");
		if(highest_pass == 0)  {
			return;
		}
		switch(highest_pass) {
		case 1, 2, 3, 4:
			switch(highest_pass) {
			case 1:
				star_e = U.gfx("star_casual_blue", "WorldMap");
				//1st star casual
				break;
			}
			switch(highest_pass) {
			case 2:
				star_e = U.gfx("blue_star", "WorldMap");
				//1st star
				break;
			}
			switch(highest_pass) {
			case 3:
				star_e = star_n = U.gfx("blue_star", "WorldMap");
				//1st & 2nd star
				break;
			}
			star_e = star_n = star_h = U.gfx("blue_star", "WorldMap");
		}
		switch(highest_perfect) {
		case 1, 2, 3, 4:
			switch(highest_perfect) {
			case 1:
				star_e = U.gfx("star_casual_gold", "WorldMap");
				//1st star casual gold
				break;
			}
			switch(highest_perfect) {
			case 2:
				star_e = U.gfx("gold_star", "WorldMap");
				//1st star gold
				break;
			}
			switch(highest_perfect) {
			case 3:
				star_e = star_n = U.gfx("gold_star", "WorldMap");
				//1st & 2nd star gold
				break;
			}
			star_e = star_n = star_h = U.gfx("gold_star", "WorldMap");
		}
		star_easy = U.FS(star_e);
		star_easy.x = 200;
		star_easy.y = (back.height - star_easy.height) / 2;
		star_normal = U.FS(star_n);
		star_normal.x = star_easy.x + star_easy.width;
		star_normal.y = star_easy.y;
		star_hard = U.FS(star_h);
		star_hard.x = star_normal.x + star_normal.width;
		star_hard.y = star_normal.y;
		add(star_easy);
		add(star_normal);
		add(star_hard);
	}

	function showStars() : Void {
		var stars : Point = prog.countStarsAchieved();
		if(prog_plus != null)  {
			var stars_plus : Point = prog_plus.countStarsAchieved();
			stars.x += stars_plus.x;
			stars.y += stars_plus.y;
		}
		if(stars.x > 0)  {
			star_blue = U.FS(U.gfx("blue_star", "WorldMap"));
			star_blue.x = 210;
			star_blue.y = ((back.height - star_blue.height) / 2) - (star_blue.height) + 10;
			add(star_blue);
			star_blue_text = new FlxTextX(star_blue.x + star_blue.width + 2, star_blue.y + 4, 100, ": 00");
			star_blue_text.setFormat("Verdana_12pt_st", 12, 0xffffff, "left", 1);
			star_blue_text.bold = true;
			star_blue_text.dropShadow = true;
			star_blue_text.text = ": " + stars.x;
			add(star_blue_text);
			star_gold = U.FS(U.gfx("gold_star", "WorldMap"));
			star_gold.x = 210;
			star_gold.y = star_blue.y + star_gold.height + 5;
			add(star_gold);
			star_gold_text = new FlxTextX(star_gold.x + star_gold.width + 2, star_gold.y + 4, 100, ": 00");
			star_gold_text.setFormat("Verdana_12pt_st", 12, 0xffffff, "left", 1);
			star_gold_text.bold = true;
			star_gold_text.dropShadow = true;
			star_gold_text.text = ": " + stars.y;
			add(star_gold_text);
		}
	}

	function showBonus() : Void {
		//showCompletion();
		showStars();
	}

	function showParty() : Void {
		var list : Vector<CharacterSave>;
		var c : CharacterSave;
		var i : Int = 0;
		var first_icon_width : Float = 0;
		var first_icon_height : Float = 0;
		for(str in data.list_classes){
			// AS3HX WARNING could not determine type for var: str exp: EField(EIdent(data),list_classes) type: null
			//We don't include zelemir
			//hack, but it works
			if(str != CharacterClass.CLASS_SORCEROR && str != CharacterClass.CLASS_ANTIMCGUFFIN)  {
				c = null;
				list = data["list_" + str + "s"];
				if(list != null)  {
					if(list.length > 0)  {
						c = list[0];
					}
				}
				if(c != null)  {
					var icon : BasicEntity = Main.factory_defender.getFastIconFromStr(str, true);
					icon.y = 22;
					if(first_icon_width == 0)  {
						first_icon_width = icon.width;
					}
					if(first_icon_height == 0)  {
						first_icon_height = icon.height;
					}
					var minus : Float = 5;
					icon.x = 280 + ((45) * i);
					var overwidth : Float = 0;
					if(icon.width > first_icon_width)  {
						overwidth = icon.width - first_icon_width;
						icon.x -= overwidth / 2;
					}
					group_icons.add(icon);
					var text : FlxTextX = new FlxTextX(icon.x - minus, icon.y + 45, icon.width, "x1");
					text.setFormat("Verdana", 16, 0xffffff, "center", 1);
					text.dropShadow = true;
					text.bold = false;
					text.text = "x" + list.length.toString();
					group_icon_texts.add(text);
				}
				i++;
			}
		}

	}
	*/
	
	function onPlus() : Void {
		/*if(ptr_state != null)  {
			ptr_state.onPlus(as3hx.Compat.parseInt(id));
		}*/
		#if debug
		//trace("press plus " + id);
		#end
	}

	function onPress() : Void {
		#if debug
		/*trace("press " + id);*/
		#end
		/*if(ptr_state != null)  {
			ptr_state.onPress(as3hx.Compat.parseInt(id));
		}*/
	}

	function cleanSlot() : Void {
		valid = false;
	}

	function onExport() : Void {
		/*if(ptr_state != null)  {
			ptr_state.onExport(as3hx.Compat.parseInt(id));
		}

		else if(ptr_state_demo != null)  {
			ptr_state_demo.onExport(as3hx.Compat.parseInt(id));
		}*/
	}

	function onImport() : Void {
		//if (Main.DEMO_MODE) return;
		/*if(ptr_state != null)  {
			ptr_state.onImport(as3hx.Compat.parseInt(id));
		}*/
	}

	function onDel() : Void {
		/*if(ptr_state != null)  {
			ptr_state.onPressDel(as3hx.Compat.parseInt(id));
		}*/
	}
}